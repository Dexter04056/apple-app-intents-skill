# Contributing

Contributions are welcome under the MIT License. Focus changes on a demonstrated integration problem, a new verified Apple API, a useful example, or a reproducible agent failure.

1. Cite current primary Apple documentation for API claims, including SDK/OS availability. Distinguish a session demonstration from a release guarantee.
2. Keep the skill entrypoint concise and place conditional detail in a focused reference.
3. Preserve portability: no required model, paid service, account credential, remote bootstrap script, or vendor-specific tool name in the core workflow.
4. Run `python3 scripts/validate.py` and `python3 -m unittest discover -s tests -v`. For Swift changes, run the example's documented checks and record unavailable device tests.
5. Add a realistic evaluation case if the change corrects agent behavior. Show the generated decision/artifact and explain the observable defect.
6. Submit a focused pull request with the problem, change, sources, and verification evidence.

Do not commit full third-party transcripts, copied articles, Apple SDK binaries, personal app data, signing assets, credentials, or private conversation logs. Link original material instead. Contributions should be your original work or have a compatible documented license.

Report bugs through GitHub Issues with a minimal reproduction, skill revision, agent/version, SDK/OS, expected behavior, and redacted output. Device testing and documentation translations are useful contributions. No contributor agreement or payment is required.
