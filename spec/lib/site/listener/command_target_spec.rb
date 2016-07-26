require 'spec_helper'

describe 'site/listening/command_target' do
  it 'can be required' do
    expect do require 'site/listening/command_target' end.not_to raise_error
  end
end

require 'site/listening/command_target'
require 'site/listening/target'
require 'site/listening/listenable'

describe Site::Listening::CommandTarget do
  it 'includes Site::Listening::Listenable' do
    expect(Site::Listening::CommandTarget).to include(Site::Listening::Listenable)
  end

  it 'inherits from Site::Listening::Target' do
    expect(Site::Listening::CommandTarget.ancestors).to include(Site::Listening::Target)
  end
end
