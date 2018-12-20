module CoreExtensions
  module StringExt
    module Validators
      def valid_html?
        Nokogiri::XML(self).errors.empty?
      end

      def is_int?
        to_i.to_s == self
      end
    end
  end
end

# This automatically includes this extension in every file. Alternatively,
# comment this line out and include the extension on a per-file basis.
String.include CoreExtensions::StringExt::Validators
