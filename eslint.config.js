import js from "@eslint/js";
import gitignore from "eslint-config-flat-gitignore";
import globals from "globals";
import tseslint from "typescript-eslint";

export default tseslint.config(
  gitignore(),
  ...tseslint.configs.recommended,
  {
    files: ["**/*.ts"],
    rules: {
      "@typescript-eslint/no-unused-vars": [
        "error",
        {
          argsIgnorePattern: "^_",
        },
      ],
    },
  },
  {
    files: ["**/*.mjs"],
    ...js.configs.recommended,
    languageOptions: {
      sourceType: "module",
      globals: globals.node,
    },
  },
);
