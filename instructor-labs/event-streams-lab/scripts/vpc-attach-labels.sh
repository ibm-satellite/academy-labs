# In the satellite location attach script
# - locate the "if" section containing...echo "echo Probing for GCP Metadata"
# - add the section of script after the "if" section for teh GCP Metadata
# - the section below needs to be in line with the other "if" section(s)
# - each line of the section below needs to be prepended with spaces (not tabs)


    if [[ -z "$ZONE" ]]; then
        echo "echo Probing for VPC Metadata"
        gather_vpc_token() {
            HTTP_RESPONSE=$(curl --write-out "HTTPSTATUS:%{http_code}" --max-time 10 -X PUT "http://169.254.169.254/instance_identity/v1/token?version=2022-03-08" -H "Metadata-Flavor: ibm" -d '{"expires_in": 3600}')
            HTTP_STATUS=$(echo "$HTTP_RESPONSE" | tr -d '\n' | sed -E 's/.*HTTPSTATUS:([0-9]{3})$/\1/')
            HTTP_BODY=$(echo "$HTTP_RESPONSE" | sed -E 's/HTTPSTATUS\:[0-9]{3}$//')
            if [[ "$HTTP_STATUS" -ne 200 ]]; then
                echo "bad return code"
                return 1
            fi
            if [[ -z "$HTTP_BODY" ]]; then
                echo "no token found"
                return 1
            fi
            echo "found aws access token"
            TOKEN=$(echo "$HTTP_BODY" | python -c "import sys, json, os; z = json.load(sys.stdin); print(z['access_token'])")
        }
        gather_vpc_zone_info() {
            HTTP_RESPONSE=$(curl --write-out "HTTPSTATUS:%{http_code}" --max-time 10 -H "Authorization: Bearer $TOKEN" http://169.254.169.254/metadata/v1/instance?version=2022-03-08)
            HTTP_STATUS=$(echo "$HTTP_RESPONSE" | tr -d '\n' | sed -E 's/.*HTTPSTATUS:([0-9]{3})$/\1/')
            HTTP_BODY=$(echo "$HTTP_RESPONSE" | sed -E 's/HTTPSTATUS\:[0-9]{3}$//')
            if [[ "$HTTP_STATUS" -ne 200 ]]; then
                echo "bad return code"
                return 1
            fi
            ZONE=$(echo "$HTTP_BODY" | python -c "import sys, json, os; z = json.load(sys.stdin); print(z['zone']['name'])")
        }
        gather_vpc_info() {
            if ! gather_vpc_token; then
                return 1
            fi
            if ! gather_vpc_zone_info; then
                return 1
            fi
        }
        if gather_vpc_info; then
            echo "vpc metadata detected"
            PROVIDER="vpc"
        fi
    fi