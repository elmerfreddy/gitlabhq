module VisibilityLevelHelper
  def visibility_level_color(level)
    case level
    when Gitlab::VisibilityLevel::PRIVATE
      'cgreen'
    when Gitlab::VisibilityLevel::INTERNAL
      'camber'
    when Gitlab::VisibilityLevel::PUBLIC
      'cblue'
    end
  end

  def visibility_level_description(level)
    capture_haml do
      haml_tag :span do
        case level
        when Gitlab::VisibilityLevel::PRIVATE
          haml_concat t('project_access_must_be_granted', scope: 'projects.new')
        when Gitlab::VisibilityLevel::INTERNAL
          haml_concat t('the_project_can_be_cloned_by', scope: 'projects.new')
          haml_concat t('any_logged_in_user', scope: 'projects.new')
        when Gitlab::VisibilityLevel::PUBLIC
          haml_concat t('the_project_can_be_cloned', scope: 'projects.new')
          haml_concat t('without_any', scope: 'projects.new')
          haml_concat t('authentication', scope: 'projects.new')
        end
      end
    end
  end

  def visibility_level_icon(level)
    case level
    when Gitlab::VisibilityLevel::PRIVATE
      private_icon
    when Gitlab::VisibilityLevel::INTERNAL
      internal_icon
    when Gitlab::VisibilityLevel::PUBLIC
      public_icon
    end
  end

  def visibility_level_label(level)
    Project.visibility_levels.key(level)
  end

  def restricted_visibility_levels
    current_user.is_admin? ? [] : gitlab_config.restricted_visibility_levels
  end
end
