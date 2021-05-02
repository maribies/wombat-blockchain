require 'spec_helper'

RSpec.describe "Humans using the app", type: :feature do
  describe 'the root page' do
    it 'greets the user' do
      page.visit "/"
      expect(page).to have_content "Welcome to the WombatChain"
    end
  end
end
