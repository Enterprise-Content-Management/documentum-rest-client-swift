CREATE TABLE basic(
id integer primary key autoincrement,
attr text not null,
value text);

insert into basic(attr, value) values('rooturl', 'http://127.0.0.1:8080');
insert into basic(attr, value) values('context','/dctm-rest');
insert into basic(attr, value) values('username','Administrator');
insert into basic(attr, value) values('password','password');
insert into basic(attr, value) values('shouldremember','false');
insert into basic(attr, value) values('shouldautologin','false');