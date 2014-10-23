require 'rails_helper'

RSpec.describe ItemCategory, type: :model do
  context 'validations' do
    it { is_expected.to validate_presence_of :name }
  end

  context 'associations' do
    it { is_expected.to have_many :items }
  end
end
