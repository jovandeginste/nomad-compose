targets=prod+ dev+2.0.1a dev+2.0.1b
ymlfiles=$(wildcard helloworld*.yml)
nomadfiles=$(wildcard helloworld*.nomad)

.PHONY: helloworld*.yml

clean:
ifneq (,$(nomadfiles))
	rm -vf $(nomadfiles)
endif

nomad: clean $(ymlfiles)

$(ymlfiles):
	../compose2nomad.rb $@
