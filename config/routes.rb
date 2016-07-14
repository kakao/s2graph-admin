Rails.application.routes.draw do

  resources :counters
  get 'talk_tabs', to: 'talk_tabs#index'
  # get 'admin/index'

  # get 'sessions/new'

  get 'sessions/create'

  get 'sessions/destroy'

  controller :sessions do
    get 'login' => :new
    post 'login' => :create
    delete 'logout' => :destroy
  end


  root to: 'experiments#index'

  resources :column_meta
  resources :label_meta
  resources :services  do
    member do
      put 'access_token', to: 'services#updateAccessToken'
    end
  end

  resources :labels, except: [:update] do
    member do
      post 'add_props_and_indices', to: 'labels#addPropsAndIndices'
    end
  end

  resources :buckets, only: [:new, :create, :edit, :show, :update, :destroy] do
    member do
      put 'copy_bucket', to: 'buckets#copyBucket'
    end
  end
  resources :services
  
  # resources :users, only: [:new, :create, :edit, :update, :destroy]
  resources :users do
    member do
      get :info
    end
  end
  resources :authorities
  resources :s2ml_apps
	resources :s2loader_jobs
  resources :s2admin_demos do
    member do
      get :demo
      get :default_id
    end
  end
  resources :experiments do
    member do
      get :detail
      post :modular
    end
  end

  post 'buckets/validate/request_body', to: 'buckets#validateRequestBody'

  get 'queries/visualize'

  post 'queries/partial_graph', to: 'queries#partialGraph'

  post 'queries/call_graph', to: 'queries#callGraph'

  get 'labels/check/:label_name', to: 'labels#check'

  get 'buckets/check/:impression_id', to: 'buckets#check'

  get 's2graph', to: 'services#index'

  get 's2counter', to: 'counters#index'

  get 'users', to: 'users#index'

  get 'access', to: 'authorities#index'

  get 's2ab', to: 'experiments#index'

  post 's2ab/:access_token/ratio-update-all', to: 'experiments#ratioUpdateAll'

  get 's2ab/:access_token/list(/:experiment_name)', to: 'experiments#list'

  get 's2ml', to: 's2ml_apps#index'

  get 's2ml_apps/:id/disable', to: 's2loader_jobs#disable'

  get 's2ml_apps/:id/enable', to: 's2loader_jobs#enable'

  get 's2loader', to: 's2loader_jobs#index'

  get 's2loader_jobs/:id/test', to: 's2loader_jobs#test'

  get 's2loader_jobs/:id/disable', to: 's2loader_jobs#disable'

  get 's2loader_jobs/:id/enable', to: 's2loader_jobs#enable'

  get 'demos', to: 's2admin_demos#index'

  get 'demos/:id/demo', to: 's2admin_demos#demo'

  get 'demos/update_descriptions', to: 's2admin_demos#update_descriptions'

  get 'demos/s2graph', to: 's2admin_demos#index'

  get 'demos/s2counter', to: 's2admin_demos#demo_counter.html.haml'

  get 'demos/talk-channel', to: 'talk_tabs#index'

  get 'links', to: 'links#list'

  get 'servers', to: 'servers#index'

  put 'servers/:server/:status', to: 'servers#toggle_health'

  get 'servers/load', to: 'servers#high_loads'

  get 'servers/latency', to: 'servers#high_latencies'
end
