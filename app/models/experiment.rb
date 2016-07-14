class Experiment < ActiveRecord::Base
  belongs_to :service
  has_many :buckets
  # TODO: move to ENV per phase
  def s2_url
    APP_CONFIG['s2graph_url']+'/graphs/getEdges'
  end

  def self.time_iterate(start_time, end_time, step, &block)
    arr = []
    begin
      yield start_time if block_given?
      arr << start_time
    end while (start_time += step) <= end_time
    arr
  end

  def make_chart(nom, denom, time_unit, _from, _to)
    begin
      is_single_action = nom == denom
      time_step =
        if time_unit.to_sym == :H
          60*60*1000
        elsif time_unit.to_sym == :d
          60*60*1000*24
        end

      from, to = (_from / time_step * time_step), (_to / time_step * time_step)

      # FIXME
      to -= 9.hours * 1000
      from -= 9.hours * 1000

      query = build_query(time_unit, from, to, [nom, denom])
      #logger.info(query.to_json)
      res = RestClient.post s2_url, query.to_json, :content_type => :json, :accept => :json
      parsed = (JSON.parse(res) rescue {}).with_indifferent_access
      results = parsed[:results]
      #logger.info results
      xAxis = Experiment.time_iterate(from, to, time_step)
      series_ls = results.map do |grouped|
        bucket_name = grouped[:groupBy][:from]

        time_action_map = {}
        grouped[:agg].each do |edge|
          props = edge[:props]
          time_value = props[:time_value]
          count = props[:_count] || props[:count] # FIXME: '_count' is correct
          action = edge[:to].split(".").last
          time_action_map["#{time_value}_#{action}"] = count.to_f
        end

        sum_top = 0
        sum_bottom = 0
        series = xAxis.map { |tm|
          _nom, _denom = "#{tm}_#{nom}", "#{tm}_#{denom}"
          bottom = is_single_action ? 1 : time_action_map.fetch(_denom, 1)
          top = time_action_map.fetch(_nom, 0)
          ctr = (top / bottom).round(5)

          sum_top += top
          sum_bottom += bottom
          ["#{nom}: #{top}<br />#{denom}: #{bottom}", ctr, {conversions: top, visitors: bottom, conversion_rate: ctr}]
        }
        g_ctr = sum_bottom == 0 ? sum_top.round(5) : (sum_top/sum_bottom).round(5)
        series.push(["overall result (#{sum_top}/#{sum_bottom})", g_ctr, {conversions: sum_top, visitors: sum_bottom, conversion_rate: g_ctr}])
        { name: bucket_name, data: series }
      end

      series_ls = series_ls.map do |test_a|
        explain_list = series_ls.map do |test_b|
          explain = []
          test_a[:data].zip(test_b[:data]).each do |data_a, data_b|
            support_sent = ''
            if test_a[:name] != test_b[:name]
              a = data_a[2]
              b = data_b[2]
              if a[:visitors] > 0 && b[:visitors] > 0 && (a[:conversion_rate] <= 1 && a[:conversion_rate] > 0 && b[:conversion_rate] <= 1 && b[:conversion_rate] > 0)
                x = Math.sqrt((a[:conversion_rate] * (1 - a[:conversion_rate])) / a[:visitors])
                y = Math.sqrt((b[:conversion_rate] * (1 - b[:conversion_rate])) / b[:visitors])
                s = (a[:conversion_rate] - b[:conversion_rate]) / Math.sqrt(x * x + y * y)
                if a[:conversion_rate] > b[:conversion_rate]
                  certainty = ExperimentsHelper.normdist(s, 0, 1, true)
                else
                  certainty = 1 - ExperimentsHelper.normdist(s, 0, 1, true)
                end
                if a[:conversion_rate] >= b[:conversion_rate]
                  if b[:conversion_rate] > 0
                    improvement = (a[:conversion_rate] - b[:conversion_rate]) / b[:conversion_rate]
                  else
                    improvement = a[:conversion_rate]
                  end
                  support_sent = "<br />certainty: #{(certainty * 100).round(2)}% improvement: #{(improvement * 100).round(2)}% over #{test_b[:name]}"
                end
              end
            end
            explain.push(support_sent)
          end
          explain
        end
        { name: test_a[:name], data: test_a[:data].each_with_index.map { |x, i| [x[0] + explain_list.map{ |e| e[i] }.join(''), x[1]] } }
      end

      ##logger.info series_ls

      sub_title = is_single_action ? nom.to_s.camelize : "#{nom.to_s.camelize} / #{denom.to_s.camelize}"
      ret = {
        chart: { zoomType: 'x' },
        title: { text: service.service_name },
        tooltip: { crosshairs: true, shared: false },
        subtitle: { text: sub_title },
        xAxis: { categories: xAxis.map{|tm| Time.at(tm/1000).strftime("%Y-%m-%d %H:%M") } << 'Overall' },
        yAxis: { title: { text: :ctr } },
        plotOptions: { line: { dataLabels: { enabled: true }, enableMouseTracking: true } },
        series: series_ls.sort_by { |h| h[:name] }
      }
      ret
    rescue => e
      nil
    end
  end

  def build_query(time_unit, from, to, action_types)
    ids = buckets.map(&:impression_id)
    sources = [ { serviceName: :s2ab, columnName: :bucket_id, ids: ids } ]

    first_step = action_types.map do |action|
      {
        direction: :out,
        duplicate: :raw,
        label: :s2ab_feedback_counts,
        limit: -1,
        offset: 0,
        interval: {
          from: {
            _to: "action_type.#{action}",
            time_unit: time_unit,
            time_value: from
          },
          to: {
            _to: "action_type.#{action}",
            time_unit: time_unit,
            time_value: to
          }
        }
      }
    end
    step_hash = { step: first_step }
    {
      groupBy: %i[from],
      srcVertices: sources,
      steps: [step_hash]
    }
  end

  def action_types
    # FIXME: just mock, move to database
    %i[click buy purchase download invite register impression]
  end
end
