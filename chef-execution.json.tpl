{
    "hashicorp-vault": {
        "version": "${version}",
        "config": {
          "address":"${address}"
        }
    },
    "run_list": [
        "recipe[${recipe}]"
    ]
}
