module Util
	def getUserName(id)
		user = User.find(id)
		if user.nil?
			return ''
		else
			return user.email.gsub(APP_CONFIG['email_postfix'], '')
		end
  end
end