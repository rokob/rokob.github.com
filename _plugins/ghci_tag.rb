module Jekyll
  class GHCiTag < Liquid::Block
    def initialize(tag_name, text, tokens)
      super
      @prompt = text.empty? ? "ghci" : text
    end

    def render(context)
      lines_to_execute = super
      site = context.registers[:site]
      converter = site.getConverterImpl(Jekyll::Converters::Markdown)
      mod = context.environments[0]['page']['path']
      result = lines_to_execute.split("\n").map do |line|
        if line != ''
          @prompt + "> " + line + "\n" + ghc_eval(line, mod)
        else
          ''
        end
      end
      converter.convert(["```haskell", result, "```"].flatten.join("\n"))
    end

    private
      def ghc_eval(line, mod)
        result = ""
        IO.popen("ghc -e \"#{line}\" #{mod}") do |f|
          result = f.gets
        end
        result.strip
      end
  end
end

Liquid::Template.register_tag('ghci', Jekyll::GHCiTag)
