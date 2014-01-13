require 'i18n'
require 'configatron'

module LookoutRackUtils
  module I18n
    ::I18n.load_path = Dir["./config/locales/**/*.yml"]
    ::I18n.default_locale = (defined?(configatron) && configatron && configatron.default_locale) || :en
    def t(*args)
      ::I18n.t(*args)
    end

    def current_locale
      return @locale unless @locale.nil?
      return :en unless defined?(configatron) && configatron

      accepted_languages.each do |lang, quality|
        if configatron.locales.include?(lang)
          @locale = lang
          return @locale
        end
      end

      # Just fallback to what we have set for the default
      @locale = configatron.default_locale
      return @locale
    end

    def accepted_languages
      accepted = request.env['HTTP_ACCEPT_LANGUAGE']
      return [] if accepted.nil?

      # parse Accept-Language
      accepted = accepted.split(',')
      accepted = accepted.map { |l| l.strip.split(";") }
      accepted = accepted.map { |l|
        # en-US -> :en
        lang = l[0].split('-').first.downcase.to_sym

        if (l.size == 2)
          # quality present
          [lang, l[1].sub(/^q=/, "").to_f ]
        else
          # no quality specified =&gt; quality == 1
          [ lang, 1.0 ]
        end
      }
      # sort by quality
      accepted.sort { |left, right| right[1] <=> left[1] }
    end
  end
end
