# frozen_string_literal: true

require 'sanitize'
require_relative 'html_transformers/transform_urls_to_absolute_ones'
require_relative 'html_transformers/wrap_img_in_a'

module Html2rss
  module AttributePostProcessors
    ##
    # Returns sanitized HTML code as String.
    #
    # It sanitizes by using the [sanitize gem](https://github.com/rgrove/sanitize) with
    # [Sanitize::Config::RELAXED](https://github.com/rgrove/sanitize#sanitizeconfigrelaxed).
    #
    # Furthermore, it adds:
    #
    # - `rel="nofollow noopener noreferrer"` to <a> tags
    # - `referrer-policy='no-referrer'` to <img> tags
    # - wraps all <img> tags, whose direct parent is not an <a>, into an <a>
    #   linking to the <img>'s `src`.
    #
    # Imagine this HTML structure:
    #
    #     <section>
    #       Lorem <b>ipsum</b> dolor...
    #       <iframe src="https://evil.corp/miner"></iframe>
    #       <script>alert();</script>
    #     </section>
    #
    # YAML usage example:
    #
    #    selectors:
    #      description:
    #        selector: '.section'
    #        extractor: html
    #        post_process:
    #          name: sanitize_html
    #
    # Would return:
    #    '<p>Lorem <b>ipsum</b> dolor ...</p>'
    class SanitizeHtml < Base
      def self.validate_args!(value, context)
        assert_type value, String, :value, context:
      end

      ##
      # Shorthand method to get the sanitized HTML.
      # @param html [String]
      # @param url [String, Addressable::URI]
      def self.get(html, url)
        raise ArgumentError, 'url must be a String or Addressable::URI' if url.to_s.empty?
        return nil if html.to_s.empty?

        new(html, { config: Config::Channel.new({ url: }) }).get
      end

      ##
      # @return [String]
      def get
        sanitized_html = Sanitize.fragment(value, sanitize_config)
        sanitized_html.to_s.gsub(/\s+/, ' ').strip
      end

      private

      ##
      # @return [Sanitize::Config]
      def sanitize_config
        Sanitize::Config.merge(
          Sanitize::Config::RELAXED,
          attributes: { all: %w[dir lang alt title translate] },
          add_attributes:,
          transformers: [
            method(:transform_urls_to_absolute_ones),
            method(:wrap_img_in_a)
          ]
        )
      end

      def add_attributes
        {
          'a' => { 'rel' => 'nofollow noopener noreferrer', 'target' => '_blank' },
          'img' => { 'referrer-policy' => 'no-referrer' }
        }
      end

      def channel_url = context[:config].url

      ##
      # Wrapper for transform_urls_to_absolute_ones to pass the channel_url.
      #
      # @param env [Hash]
      # @return [nil]
      def transform_urls_to_absolute_ones(env)
        HtmlTransformers::TransformUrlsToAbsoluteOnes.new(channel_url).call(**env)
      end

      ##
      # Wrapper for wrap_img_in_a.
      #
      # @param env [Hash]
      # @return [nil]
      def wrap_img_in_a(env)
        HtmlTransformers::WrapImgInA.new.call(**env)
      end
    end
  end
end
