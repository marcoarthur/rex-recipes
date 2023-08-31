.PHONY: test list help

host := perl.dev #default host
task := -T # list all by default

# topt: task options
# ropt: rex options
run:        ## run a task, args: task=task_name host=host_name topt="--task_arg=val --task_arg2=val2 ..."
	rex $(ropt) -H $(host) $(task) $(topt)
ls:         ## list all tasks
	rex -T | sed -n -e '/Tasks/,/Batches/ p'
help:       ## Show this help
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'
