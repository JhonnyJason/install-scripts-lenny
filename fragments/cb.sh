## here create the desired users and tables for the postgresql db
su postgres -c 'createuser {{{dbUserName}}}'
su postgres -c 'createdb {{{dbName}}} -O {{{dbUserName}}}'