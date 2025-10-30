{
  "schema": "olm.package",
  "name": "webhook-operator",
  "defaultChannel": "alpha"
}
{
  "schema": "olm.channel",
  "name": "alpha",
  "package": "webhook-operator",
  "entries": [
    {
      "name": "webhook-operator.v{{ VERSION }}"
    }
  ]
}
