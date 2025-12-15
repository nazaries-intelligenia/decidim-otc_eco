# frozen_string_literal: true

module Decidim
  module UserGroupFormOverride
    extend ActiveSupport::Concern

    included do
      attribute :address
      attribute :latitude, Float
      attribute :longitude, Float
      attribute :ec_agents
      attribute :installed_power
      attribute :legal_form
      attribute :creation_date, Date
      attribute :action_types
      attribute :financial_support
      attribute :project_website
      attribute :contact_person
      attribute :privacy_policy_accepted

      validates :address, presence: true
      validates :name, format: { with: Decidim::UserBaseEntity::REGEXP_NAME }
      validates :nickname, format: { with: Decidim::UserBaseEntity::REGEXP_NICKNAME }
      validates :project_website, format: { with: URI::DEFAULT_PARSER.make_regexp(%w(http https)), allow_blank: true }
      validates :ec_agents, :installed_power, :legal_form, :creation_date, :action_types, :contact_person,
                presence: true
      validates :privacy_policy_accepted, acceptance: true
    end

    def map_model(model)
      self.ec_agents = model.extended_data["ec_agents"]
      self.installed_power = model.extended_data["installed_power"]
      self.legal_form = model.extended_data["legal_form"]
      self.creation_date = Date.parse(model.extended_data["creation_date"]) if model.extended_data["creation_date"].present?
      self.action_types = model.extended_data["action_types"]
      self.financial_support = model.extended_data["financial_support"]
      self.project_website = model.extended_data["project_website"]
      self.contact_person = model.extended_data["contact_person"]
    end
  end
end
