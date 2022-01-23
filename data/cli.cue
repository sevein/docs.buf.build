package data

_vals: {
	registry: "Interact with the Buf Schema Registry (BSR)."
	commit_arg: {
		description: "The commit."
		format:      #Commit
	}
	config_opt: {
		description: "The template config file or data to use. Must be in either YAML or JSON format."
		type:        "string"
	}
	force_flag: {
		description: """
			Force deletion without confirming. Use with caution.
			"""
	}
	format_opt: {
		description: "The output format to use."

		enum: {
			text: "Plaintext."
			JSON: "JSON."
		}
		default: "text"
	}
	message_opt: {
		description: """
			The deprecation message to display with deprecation
			warnings.
			"""
		type: "string"
	}
	organization_arg: {
		description: "The organization."
		format:      #Organization
	}
	page_size_opt: {
		description: "The page size."
		type:        "uint32"
		default:     10
	}
	page_token_opt: {
		description: """
			The page token. If more results are available, a
			`next_page` key will be present in the `--format=json`
			output.
			"""
		type: "string"
	}
	plugin_arg: {
		description: "The plugin."
		format:      #Plugin
	}
	repository_arg: {
		description: "The repository."
		format:      #Repository
	}
	reverse_flag: {
		description: "Reverse the results."
	}
	tag_arg: {
		description: "The tag."
		format:      #Tag
	}
	target_arg: {
		description: "The target."
		format:      #Target
	}
	template_arg: {
		description: "The template."
		format:      #Template
	}
	visibility_opt: {
		description: "The plugin's visibility setting."
		enum: {
			private: "Make the plugin private."
			public:  "Make the plugin public."
		}
	}
}

buf_cli: {
	name: "buf"

	global_flags: {
		debug: {
			description: "Turn on debug logging."
		}

		help: {
			description: "Help text for the CLI."

			_short: "h"
		}

		verbose: {
			description: "TODO"

			_short: "v"
		}

		version: {
			description: "Print the Buf CLI version."
		}
	}

	options: {
		"log-format": {
			description: "The output format for log messages."
			default:     "color"
			enum: {
				text:  "Text output"
				color: "Colored text output"
				json:  "JSON output"
			}
		}

		timeout: {
			description: "The duration until timing out."
			type:        "duration"
			default:     "2m0s"
		}
	}

	commands: {
		beta: {
			description: "Beta commands. Unstable and likely to change."

			commands: {
				registry: {
					description: _vals.registry

					commands: {
						commit: {
							description: "Repository commit commands."

							commands: {
								get: {
									description: "Get commit defails."

									args: [_vals.target_arg]

									options: {
										format: _vals.format_opt
									}
								}

								list: {
									description: "List commit details."

									args: [_vals.target_arg]

									flags: {
										reverse: _vals.reverse_flag
									}

									options: {
										format: _vals.format_opt

										"page-size": _vals.page_size_opt

										"page-token": _vals.page_token_opt
									}
								}
							}
						}

						organization: {
							description: "Organization commands."

							commands: {
								create: {
									description: "Create a new organization."

									args: [_vals.organization_arg]

									options: {
										format: _vals.format_opt
									}
								}

								delete: {
									description: "Delete an organization by name."

									args: [_vals.organization_arg]

									flags: {
										force: _vals.force_flag
									}
								}

								get: {
									description: "Get an organization by name."

									args: [_vals.organization_arg]

								}
							}
						}

						plugin: {
							description: "Plugin commands."

							commands: {
								create: {
									description: "Create a new plugin."

									args: [_vals.plugin_arg]

									options: {
										format:     _vals.format_opt
										visibility: _vals.visibility_opt
									}
								}

								delete: {
									description: "Delete a plugin by name."

									args: [_vals.plugin_arg]

									flags: {
										force: _vals.force_flag
									}
								}

								deprecate: {
									description: "Deprecate a plugin by name."

									args: [_vals.plugin_arg]

									options: {
										message: _vals.message_opt
									}
								}

								list: {
									description: "List plugins associated with this user."

									flags: {
										reverse: _vals.reverse_flag
									}

									options: {
										format:       _vals.format_opt
										"page-size":  _vals.page_size_opt
										"page-token": _vals.page_token_opt
									}
								}

								undeprecate: {
									description: "Undeprecate a plugin by name."

									args: [_vals.plugin_arg]
								}

								version: {
									description: "Plugin version commands."

									commands: {
										list: {
											description: "List available versions for the specified plugin."

											args: [_vals.plugin_arg]

											flags: {
												reverse: _vals.reverse_flag
											}

											options: {
												format:       _vals.format_opt
												"page-size":  _vals.page_size_opt
												"page-token": _vals.page_token_opt
											}
										}
									}
								}
							}
						}

						repository: {
							description: "Repository commands."

							commands: {
								create: {
									description: "Create a new repository."

									args: [ _vals.repository_arg]

									options: {
										format:     _vals.format_opt
										visibility: _vals.visibility_opt
									}
								}

								delete: {
									description: "Delete a repository by name."

									args: [_vals.repository_arg]

									flags: {
										force: _vals.force_flag
									}
								}

								deprecate: {
									description: "Deprecate a repository by name."

									args: [_vals.repository_arg]

									options: {
										message: _vals.message_opt
									}
								}

								get: {
									description: "Get a repository by name."

									args: [_vals.repository_arg]

									options: {
										format: _vals.format_opt
									}
								}

								list: {
									description: "List repositories."

									args: [_vals.repository_arg]

									flags: {
										reverse: _vals.reverse_flag
									}

									options: {
										format:       _vals.format_opt
										"page-size":  _vals.page_size_opt
										"page-token": _vals.page_token_opt
									}
								}

								undeprecate: {
									description: "Undeprecate a repository."

									args: [_vals.repository_arg]
								}
							}
						}

						tag: {
							description: "Repository tag commands."

							commands: {
								create: {
									description: "Create a tag for the specified commit."

									args: [_vals.commit_arg, _vals.tag_arg]

									options: {
										format: _vals.format_opt
									}
								}

								list: {
									description: "List tags for the specified repository."

									args: [_vals.repository_arg]

									flags: {
										reverse: _vals.reverse_flag
									}

									options: {
										format: _vals.format_opt

										"page-size": _vals.page_size_opt

										"page-token": _vals.page_token_opt
									}
								}
							}
						}

						template: {
							description: "Template version commands."

							commands: {
								create: {
									description: "Create a new template."

									args: [_vals.template_arg]

									options: {
										config: _vals.config_opt

										format: _vals.format_opt

										visibility: _vals.visibility_opt
									}
								}

								delete: {
									description: "Delete a template by name."

									args: [_vals.template_arg]

									flags: {
										force: _vals.force_flag
									}
								}

								deprecate: {
									description: "Deprecate a template by name."

									args: [_vals.template_arg]

									options: {
										message: _vals.message_opt
									}
								}

								list: {
									description: "List templates on the specified remote."

									args: [_vals.repository_arg]

									flags: {
										reverse: _vals.reverse_flag
									}

									options: {
										format:       _vals.format_opt
										"page-size":  _vals.page_size_opt
										"page-token": _vals.page_token_opt
									}
								}

								undeprecate: {
									description: "Undeprecate a template by name."

									args: [_vals.template_arg]
								}

								version: {
									description: "Template version commands."

									commands: {
										create: {
											description: "Create a new template version."

											args: [_vals.template_arg]

											options: {
												config: _vals.config_opt
												format: _vals.format_opt
												name: {
													description: "The name of the new template version."
													type:        "string"
												}
											}
										}

										list: {
											description: "List versions for the specified template."

											args: [_vals.template_arg]

											flags: {
												reverse: _vals.reverse_flag
											}

											options: {
												format:       _vals.format_opt
												"page-size":  _vals.page_size_opt
												"page-token": _vals.page_token_opt
											}
										}
									}
								}
							}
						}
					}
				}
			}
		}

		registry: {
			description: _vals.registry

			commands: {
				login: {
					description: """
						Log into the Buf Schema Registry (BSR).

						This prompts for your BSR username and a BSR token and updates your `.netrc` file with
						these credentials.
						"""

					flags: {
						"token-stdin": {
							description: """
								Read the token from stdin. By default, this command prompts for a token.
								"""
						}
					}

					options: {
						username: {
							description: "The username to user. By default, this command prompts for a username."
							type:        "string"
						}
					}
				}

				logout: {
					description: """
						Log out of the Buf Schema Registry (BSR).

						This removes any BSR credentials from your `.netrc` file.
						"""
				}
			}
		}
	}
}
