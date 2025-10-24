# frozen_string_literal: true

module Decidim
  # Controller to manage user group credentials (CIF and password)
  class UserGroupCredentialsController < Decidim::ApplicationController
    include UserGroups
    include FormFactory

    helper_method :user_group

    def edit
      enforce_permission_to :manage, :user_group, user_group: user_group

      @form = form(UserGroupCredentialsForm).from_model(user_group)
    end

    def update
      enforce_permission_to :manage, :user_group, user_group: user_group

      @form = form(UserGroupCredentialsForm).from_params(params)

      UpdateUserGroupCredentials.call(user_group, @form) do
        on(:ok) do
          flash[:notice] = I18n.t("user_group_credentials.update.success", scope: "decidim")
          redirect_to profile_members_path(nickname: user_group.nickname)
        end

        on(:invalid) do
          flash.now[:alert] = I18n.t("user_group_credentials.update.error", scope: "decidim")
          render :edit
        end
      end
    end

    private

    def user_group
      @user_group ||= Decidim::UserGroup.find_by(
        nickname: params[:nickname],
        decidim_organization_id: current_organization.id
      )
    end
  end
end
