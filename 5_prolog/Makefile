.PHONY: run

run:
	swipl -q -s program.pl -g main_ci --stack_limit=64g --table_space=64g

run_full:
	swipl -q -s program.pl -g main --stack_limit=64g --table_space=64g

debug:
	swipl -q -s program.pl -g 'gspy(second_part), main' --stack_limit=32g --table_space=32g

setup_ci:
	sudo apt-get install -y swi-prolog

