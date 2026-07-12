# Mentova — developer tasks.

# Regenerate the committed lattice snapshot (open-source / ARC-AGI-3 prize compliance):
# materialise the full Causalontology lattice (node-facts + CROs) and the essential
# per-game learned knowledge into data/lattice_snapshot/. Secrets are never included.
.PHONY: lattice-snapshot
lattice-snapshot:
	swipl -q -g true -t halt tools/lattice_export.pl

# Verify every committed lattice snapshot file still parses as Prolog terms.
.PHONY: lattice-snapshot-verify
lattice-snapshot-verify:
	@for f in data/lattice_snapshot/*.pl; do \
	  swipl -q -g "catch((open('$$f',read,S),(repeat,read_term(S,T,[]),T==end_of_file,!),close(S),format('ok ~w~n',['$$f'])),E,(format('ERR ~w ~w~n',['$$f',E]),halt(1)))" -t halt; \
	done
