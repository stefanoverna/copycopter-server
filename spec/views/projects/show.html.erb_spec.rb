require 'spec_helper'

describe '/projects/show' do
  before do
    @project = create(:project)
    @project.create_defaults 'en.test' => 'value'
    @localizations = [build_stubbed(:localization)]
    @locale = @project.locales.first

    view.stubs :cache

    render :template => '/projects/show'
  end

  it 'caches the localization json list' do
    suffix = "#{@project.etag}_#{@locale.key}_json"
    view.should have_received(:cache).with(:action_suffix => suffix)
  end
end

