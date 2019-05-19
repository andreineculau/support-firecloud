SF_CLEAN_FILES := \

# ------------------------------------------------------------------------------

.PHONY: clean
clean: ## Clean.
	[[ "$(words $(SF_CLEAN_FILES))" = "0" ]] || { \
		$(ECHO_DO) "Cleaning..."; \
		$(RM) $(SF_CLEAN_FILES); \
		$(ECHO_DONE); \
	}


.PHONY: nuke
nuke: ## Nuke all files/changes not checked in.
	$(ECHO_DO) "Nuking..."
	$(GIT) reset -- .
	$(GIT) submodule foreach --recursive "$(GIT) reset -- ."
	$(GIT) checkout HEAD -- .

	$(GIT) clean -xdf -- .
	$(GIT) submodule foreach --recursive "$(GIT) checkout HEAD -- ."
	$(GIT) submodule foreach --recursive "$(GIT) clean -xdf -- ."
	$(ECHO_DONE)


.PHONY: clobber
clobber: nuke
	: