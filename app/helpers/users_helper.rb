# frozen_string_literal: true

module UsersHelper
  def roles_collection
    User.roles.to_a.collect { |c| [Setting.present_roles[c[0].to_sym], c[0]] }
  end

  def omniauth_display_name(provider)
    case provider
    when :ldap
      provider.to_s.upcase
    else
      OmniAuth::Utils.camelize(provider).sub('Oauth2', '')
    end
  end
end
