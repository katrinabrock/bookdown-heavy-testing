rm -rf \
    env-main \
    out-main \
    env-test \
    out-test \
    env-base/renv/library \
    env-base/renv/staging \
    travis-blogdown 

cd /opt
git config --global --add safe.directory /opt/
for dir in `ls -d in-*`; do
    git config --global --add safe.directory /opt/${dir}
    cd /opt/${dir}
    git clean -df
    cd /opt
done