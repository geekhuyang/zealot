# frozen_string_literal: true

module SettingHelper
  extend ActiveSupport::Concern

  REPO_URL = 'https://github.com/tryzealot/zealot'

  class_methods do
    include ActionView::Helpers::TranslationHelper

    def present_schemes
      [
        t('settings.default_schemes.beta', default: nil),
        t('settings.default_schemes.adhoc', default: nil),
        t('settings.default_schemes.production', default: nil)
      ].compact
    end

    def present_roles
      {
        user: t('settings.default_role.user', default: nil),
        developer: t('settings.default_role.developer', default: nil),
        admin: t('settings.default_role.admin', default: nil)
      }
    end

    def site_https
      Rails.env.production? || ENV['ZEALOT_USE_HTTPS'].present?
    end

    def site_configs
      group_configs.each_with_object({}) do |(scope, items), obj|
        obj[scope] = items.each_with_object({}) do |item, inner|
          key = item[:key]
          value = send(key.to_sym)
          inner[key] = {
            value: value,
            readonly: item[:readonly]
          }
        end
      end
    end

    def need_restart?
      Rails.configuration.x.restart_required == true
    end

    def restart_required!
      Rails.configuration.x.restart_required = true
    end

    def clear_restart_flag!
      Rails.configuration.x.restart_required = false
    end

    def find_or_default(var:)
      find_by(var: var) || new(var: var)
    end

    def group_configs
      defined_fields.select { |v| v[:options][:display] == true }.group_by { |v| v[:scope] || :misc }
    end

    def host
      "#{protocol}#{site_domain}"
    end

    def protocol
      site_https ? 'https://' : 'http://'
    end

    def url_options
      {
        host: site_domain,
        protocol: protocol,
        trailing_slash: false
      }
    end

    def repo_url
      REPO_URL
    end

    def default_domain
      site_https ? 'localhost' : "localhost:#{ENV['ZEALOT_PORT'] || 3000}"
    end
  end
end