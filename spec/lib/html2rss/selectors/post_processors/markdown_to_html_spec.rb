# frozen_string_literal: true

RSpec.describe Html2rss::Selectors::PostProcessors::MarkdownToHtml do
  subject { described_class.new(markdown, config:).get }

  let(:html) do
    ['<h1>Section</h1>',
     '<p>Price: 12.34</p>',
     '<ul>',
     '<li>Item 1</li>',
     '<li>Item 2</li>',
     '</ul>',
     "<p><code>puts 'hello world'</code></p>"].join(' ')
  end
  let(:markdown) do
    <<~MD
      # Section

      Price: 12.34

      - Item 1
      - Item 2

      `puts 'hello world'`
    MD
  end
  let(:config) do
    { channel: { title: 'Example: questions', url: 'https://example.com/questions' },
      selectors: { items: {} } }
  end

  it { expect(described_class).to be < Html2rss::Selectors::PostProcessors::Base }

  it { is_expected.to eq html }
end
