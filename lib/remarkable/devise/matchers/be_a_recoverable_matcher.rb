module Remarkable
  module Devise
    module Matchers
      class BeARecoverableMatcher < Base
        assertions :included?, :has_reset_password_token_column?

        protected

        def included?
          subject_class.ancestors.include?(::Devise::Models::Recoverable)
        end
      end

      def be_a_recoverable
        BeARecoverableMatcher.new
      end
    end
  end
end
