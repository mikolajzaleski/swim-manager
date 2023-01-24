CREATE or REPLACE PROCEDURE public.dodaj_klub(IN vnazwa_klubu character varying)
    LANGUAGE plpgsql
    AS $$
declare
selected_kl kluby%rowtype;
begin
	select * from kluby into selected_kl where nazwa_klubu=vnazwa_klubu;
	if not found then
	insert into kluby(nazwa_klubu) values(vnazwa_klubu);
	else 
	RAISE NOTICE 'Klub o nazwie % już w bazie',selected_kl.nazwa_klubu;
	end if;
end ;
$$;
