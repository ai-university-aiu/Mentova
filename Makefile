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

# THE LATTICE BRIDGE (Order Two): validate the exported Causalontology 2.0.0
# type-tier snapshot — every record schema-, semantics-, identity- and
# signature-conformant — AND re-run the 107 conformance vectors (Order One's
# harness), proving the snapshot is 2.0.0-conformant and self-verifying.
.PHONY: lattice-2_0_0-validate
lattice-2_0_0-validate:
	swipl -q -g v2_main -t "halt(1)" tools/validate_causalontology_2_0_0.pl

# THE LATTICE BRIDGE (Order Two): publish the type-tier snapshot (the laws) to a
# running Causalontology commons store and read the frontier (GET /gaps) back.
# The token tier (episodic memory) is LOCAL BY DEFAULT and never published here.
# Point CAUSALONTOLOGY_STORE at the store (default http://127.0.0.1:8785).
.PHONY: lattice-2_0_0-publish
lattice-2_0_0-publish:
	swipl -q -g lp_main -t "halt(1)" tools/lattice_publish.pl
