module GroupsHelper
  def remove_user_from_group_message(group, user)
    t('are_you_sure_remove_user', scope: 'projects.team_members.users_group', user: user.name, group: group.name)
  end

  def leave_group_message(group)
    t('are_you_sure_leave_group', scope: 'projects.team_members.users_group', group: group)
  end

  def should_user_see_group_roles?(user, group)
    if user
      user.is_admin? || group.members.exists?(user_id: user.id)
    else
      false
    end
  end

  def group_head_title
    title = @group.name

    title = if current_action?(:issues)
              "#{I18n.t('issues', scope: 'admin.dashboard.index')} - " + title
            elsif current_action?(:merge_requests)
              "#{I18n.t('merge_requests', scope: 'admin.dashboard.index')} - " + title
            elsif current_action?(:members)
              "#{I18n.t('members', scope: 'projects.settings_nav')} - " + title
            elsif current_action?(:edit)
              "#{I18n.t('general.settings')} - " + title
            else
              title
            end

    title

  end
end
