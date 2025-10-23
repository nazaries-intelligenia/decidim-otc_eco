# frozen_string_literal: true

module Decidim
  # A command to update the CIF and password for a user group
  class UpdateUserGroupCredentials < Decidim::Command
    # Public: Initializes the command.
    #
    # user_group - The UserGroup to update
    # form - The form object with the data
    def initialize(user_group, form)
      @user_group = user_group
      @form = form
    end

    # Executes the command. Broadcasts these events:
    #
    # - :ok when everything is valid.
    # - :invalid if the form wasn't valid and we couldn't proceed.
    #
    # Returns nothing.
    def call
      return broadcast(:invalid) if form.invalid?

      update_credentials
      broadcast(:ok)
    end

    private

    attr_reader :form, :user_group

    def update_credentials
      Decidim.traceability.update!(
        user_group,
        form.current_user,
        cif: form.cif,
        datadis_password: form.datadis_password
      )
    end
  end
end
