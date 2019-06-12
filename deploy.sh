source localdev-config.json

if which wskdeploy >/dev/null; then
    wskdeploy -m manifest.yml --param "services.cloudant.url" "$CLOUDANT_URL" --param "services.cloudant.database" "$CLOUDANT_DATABASE"
else
    echo "wskdeploy not found on system path"
fi
