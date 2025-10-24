# frozen_string_literal: true

module Decidim
  module CreateUserGroupOverride
    extend ActiveSupport::Concern

    included do
      attr_reader :form, :user_group

      def call
        return broadcast(:invalid) if form.invalid?

        with_events(with_transaction: true) do
          create_user_group
          create_membership
          create_assembly
          create_main_data_content_block
          create_debates_component
          create_initial_debates
          add_members_as_private_users
        end
        notify_admins

        broadcast(:ok, @user_group)
      end

      private

      def create_user_group
        @user_group = UserGroup.create!(
          email: form.email,
          name: form.name,
          nickname: form.nickname,
          organization: form.current_organization,
          about: form.about,
          avatar: form.avatar,
          extended_data: {
            phone: form.phone,
            document_number: form.document_number,
            rejected_at: nil,
            verified_at: Time.current
          }
        )
      end

      def create_assembly
        @assembly = Decidim::Assembly.create!(
          organization: form.current_organization,
          title: { form.current_organization.default_locale => @user_group.name },
          subtitle: { form.current_organization.default_locale => "" },
          short_description: { form.current_organization.default_locale => @user_group.about || "" },
          description: { form.current_organization.default_locale => @user_group.about || "" },
          slug: nickname_to_slug(@user_group.nickname),
          user_group: @user_group,
          published_at: Time.current,
          private_space: true,
          is_transparent: false
        )
      end

      def create_main_data_content_block
        Decidim::ContentBlock.create!(
          decidim_organization_id: form.current_organization.id,
          manifest_name: "main_data",
          scope_name: "assembly_homepage",
          scoped_resource_id: @assembly.id,
          published_at: Time.current,
          weight: 1
        )
      end

      def create_debates_component
        @debates_component = Decidim::Component.create!(
          manifest_name: :debates,
          name: { form.current_organization.default_locale => "Foro" },
          participatory_space: @assembly,
          published_at: Time.current,
          settings: {
            comments_enabled: true
          }
        )
      end

      def create_initial_debates
        debate_keys = [
          :steering_committee,
          :community_notices,
          :driving_group,
          :projects_financing,
          :community_dynamization,
          :alliances_sustainability,
          :improvement_suggestions,
          :energy_saving
        ]

        debate_keys.each do |key|
          Decidim::Debates::Debate.create!(
            component: @debates_component,
            title: I18n.available_locales.index_with { |locale| I18n.t("decidim.components.debates.initial_debates.titles.#{key}", locale: locale) },
            description: I18n.available_locales.index_with { |_locale| "" },
            author: @user_group,
            start_time: nil,
            end_time: nil
          )
        end
      end

      def add_members_as_private_users
        @user_group.users.each do |user|
          Decidim::ParticipatorySpacePrivateUser.create!(
            user: user,
            privatable_to: @assembly,
            published: true
          )
        end
      end

      def nickname_to_slug(nickname)
        slug = nickname.dup
        slug.gsub!("_", "-")
        slug.prepend("a") unless slug[0] =~ /[A-Za-z]/
        slug.gsub!(/[^A-Za-z0-9-]/, "")

        slug
      end
    end
  end
end
