#!/usr/bin/env bash
# Decripta e exporta segredos para o ambiente
export OPENAI_API_KEY=$(age -d -i ~/.age-key.txt ~/.password-store/axis/openai-key.age)
