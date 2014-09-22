.PHONY: mruby
mruby:
	@for idx in mruby_test_*.rb; do \
		echo; \
		echo "=> $$idx:"; \
		mruby $$idx;\
	done;

.PHONY: ruby
ruby:
	@ruby -I. -e 'ARGV.each{ |f| require f if !f.match(/^-/)}' *test_*.rb
