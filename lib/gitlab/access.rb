# Gitlab::Access module
#
# Define allowed roles that can be used
# in GitLab code to determine authorization level
#
module Gitlab
  module Access
    GUEST     = 10
    REPORTER  = 20
    DEVELOPER = 30
    MASTER    = 40
    OWNER     = 50

    class << self
      def values
        options.values
      end

      def options
        {
          I18n.t('guest', scope: 'general.access')     => GUEST,
          I18n.t('reporter', scope: 'general.access')  => REPORTER,
          I18n.t('developer', scope: 'general.access') => DEVELOPER,
          I18n.t('master', scope: 'general.access')    => MASTER,
        }
      end

      def options_with_owner
        options.merge(
          I18n.t('owner', scope: 'general.access') => OWNER
        )
      end

      def sym_options
        {
          guest:     GUEST,
          reporter:  REPORTER,
          developer: DEVELOPER,
          master:    MASTER,
        }
      end
    end

    def human_access
      Gitlab::Access.options_with_owner.key(access_field)
    end

    def owner?
      access_field == OWNER
    end
  end
end
