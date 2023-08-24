.PHONY: test list help

host := perl.dev #default host
task := -T # list all by default

run:        ## run a task, args: task=task_name host=host_name
	rex $(opt) -H $(host) $(task)
ls:         ## list all tasks
	rex -T | sed -n -e '/Tasks/,/Batches/ p'
help:       ## Show this help
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'
