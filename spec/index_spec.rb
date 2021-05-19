require 'spec_helper'

RSpec.describe "Humans using the app", type: :feature do
  describe 'the root page' do
    it 'greets the user' do
      page.visit "/"
      expect(page).to have_content "Welcome to the WombatChain"
    end
  end

  describe 'making a transaction' do
    pending 'errors if missing all values' do
      page.visit "/"
      page.find("#makeTransaction").click
      expect(page).to have_content "Missing values"
    end

    pending 'errors if missing a value' do
      page.visit "/"
      page.fill_in 'transaction[sender]', with: 'my address'
      page.find("#makeTransaction").click
      expect(page).to have_content "Missing values"
    end

    it 'creates a success if given values' do
      page.visit "/"
      page.fill_in 'transaction[sender]', with: 'my address'
      page.fill_in 'transaction[recipient]', with: 'your address'
      page.fill_in 'transaction[amount]', with: 3
      page.find("#makeTransaction").click
      # TODO: See if can get beyond this back to index with success flash.
      expect(page).to have_content "{\"message\":\"Transaction will be added to Block 2\"}"
    end
  end
end
