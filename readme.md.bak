docker exec -it opensearch bash
/usr/share/opensearch/plugins/opensearch-security/tools/securityadmin.sh \
-cd /usr/share/opensearch/config/opensearch-security \
-icl \
-key /usr/share/opensearch/config/kirk-key.pem \
-cert /usr/share/opensearch/config/kirk.pem \
-cacert /usr/share/opensearch/config/root-ca.pem \
-nhnv


------------------------------------

docker exec -it opensearch bash
/usr/share/opensearch/plugins/opensearch-security/tools/securityadmin.sh \
-cd /usr/share/opensearch/config/opensearch-security \
-icl \
-key /usr/share/opensearch/config/kirk-key.pem \
-cert /usr/share/opensearch/config/kirk.pem \
-cacert /usr/share/opensearch/config/root-ca.pem \
-nhnv


docker exec -it opensearch bash -c "/usr/share/opensearch/plugins/opensearch-security/tools/securityadmin.sh -cd /usr/share/opensearch/config/opensearch-security -icl -key /usr/share/opensearch/config/kirk-key.pem -cert /usr/share/opensearch/config/kirk.pem -cacert /usr/share/opensearch/config/root-ca.pem -nhnv"

----------------------

docker exec -it opensearch bash -c "/usr/share/opensearch/plugins/opensearch-security/tools/hash.sh -p BWbqXm_z12"


---------------------


chmod 644 volumes/opensearch-dashboard/opensearch_dashboards.yml
chmod 644 volumes/opensearch/config.yml
chmod 644 volumes/opensearch/custom-config/config.yml
chmod 644 volumes/opensearch/custom-config/roles_mapping.yml
chmod 600 volumes/opensearch/custom-config/internal_users.yml


.--------------------
docker-compose -f opensearch.yml stop opensearch-dashboards && docker-compose -f opensearch.yml rm -f opensearch-dashboards && docker-compose -f opensearch.yml up -d