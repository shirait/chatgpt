module UsersHelper
  def user_role_select_options
    User.roles.keys.map { |k| [t("activerecord.attributes.user.#{k}"), k] }
  end
end
