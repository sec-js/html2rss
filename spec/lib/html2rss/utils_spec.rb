# frozen_string_literal: true

RSpec.describe Html2rss::Utils do
  describe '.build_absolute_url_from_relative(url, channel_url)' do
    let(:channel_url) { 'https://example.com' }

    {
      '/sprite.svg#play' => 'https://example.com/sprite.svg#play',
      '/search?q=term' => 'https://example.com/search?q=term'
    }.each_pair do |url, uri|
      it {
        expect(described_class.build_absolute_url_from_relative(url, channel_url).to_s).to eq uri
      }
    end
  end

  describe '.sanitize_url(url)' do
    let(:examples) do
      {
        nil => nil,
        ' ' => nil,
        'http://example.com/ ' => 'http://example.com/',
        'http://ex.ampl/page?sc=345s#abc' => 'http://ex.ampl/page?sc=345s#abc',
        'https://example.com/sprite.svg#play' => 'https://example.com/sprite.svg#play',
        'mailto:bogus@void.space' => 'mailto:bogus@void.space',
        'http://übermedien.de' => 'http://xn--bermedien-p9a.de/',
        'http://www.詹姆斯.com/' => 'http://www.xn--8ws00zhy3a.com/'
      }
    end

    it 'sanitizes the url', :aggregate_failures do
      examples.each_pair do |url, out|
        expect(described_class.sanitize_url(Addressable::URI.parse(url))).to eq(Addressable::URI.parse(out)), url
      end
    end
  end

  describe '.use_zone(time_zone)' do
    context 'without given block' do
      it do
        expect { described_class.use_zone('Europe/Berlin') }.to raise_error ArgumentError, /block is required/
      end
    end
  end

  describe '.titleized_channel_url' do
    {
      'http://www.example.com' => 'www.example.com',
      'http://www.example.com/foobar' => 'www.example.com: Foobar',
      'http://www.example.com/foobar/baz' => 'www.example.com: Foobar Baz'
    }.each_pair do |url, expected|
      it { expect(described_class.titleized_channel_url(Addressable::URI.parse(url))).to eq(expected) }
    end
  end

  describe '.titleized_url' do
    {
      'http://www.example.com' => '',
      'http://www.example.com/foobar/' => 'Foobar',
      'http://www.example.com/foobar/baz.txt' => 'Foobar Baz',
      'http://www.example.com/foo-bar/baz_qux.pdf' => 'Foo Bar Baz Qux',
      'http://www.example.com/foo%20bar/baz%20qux.php' => 'Foo Bar Baz Qux',
      'http://www.example.com/foo%20bar/baz%20qux-4711.html' => 'Foo Bar Baz Qux 4711'
    }.each_pair do |url, expected|
      it { expect(described_class.titleized_url(Addressable::URI.parse(url))).to eq(expected) }
    end
  end

  describe '.build_regexp_from_string(string)' do
    {
      '/\\d/' => /\d/,
      '\\d' => /\d/,
      '/[aeo]/' => /[aeo]/
    }.each_pair do |string, expected|
      it { expect(described_class.build_regexp_from_string(string)).to eq expected }
    end
  end
end
