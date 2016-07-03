require 'rails_helper'

RSpec.describe Api::V1::ComicsController, :type => :controller do
  render_views

  context 'index' do
    before do
      Fabricate(:comic) do
        title 'comic_1'
        publisher { Fabricate(:publisher, name: 'DARK HORSE COMICS') }
      end
      Fabricate(:comic) do
        title 'comic_2'
        publisher { Fabricate(:publisher, name: 'MARVEL COMIC') }
      end
    end
  end
end
