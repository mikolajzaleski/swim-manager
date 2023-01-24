CREATE or REPLACE PROCEDURE public.dodaj_zawodnika(IN vimie character varying, IN vnazwisko character varying, IN vpesel numeric, IN vulica character varying, IN vkod_pocztowy character varying, IN vmiejscowosc character varying, IN vnumer_domu integer, IN vnumer_lokalu integer, IN vnazwa_klubu character varying, IN plec character)
    LANGUAGE plpgsql
    AS $$
declare
selected_adr dane_adresowe%rowtype;
selected_zaw zawodnicy%rowtype;
selected_kl kluby%rowtype;
begin

select * from dane_adresowe into selected_adr where vmiejscowosc=miejscowosc and (vulica=ulica or (vulica is null and ulica is null)) and vnumer_domu=numer_budynku and (vnumer_lokalu=numer_lokalu or (vnumer_lokalu is null and numer_lokalu is null)) and vkod_pocztowy=kod_pocztowy;
if not found then
	insert into dane_adresowe(miejscowosc,ulica,numer_budynku,numer_lokalu,kod_pocztowy) values(vmiejscowosc,vulica,vnumer_domu,vnumer_lokalu,vkod_pocztowy);
end if;

select * from kluby into selected_kl where nazwa_klubu=vnazwa_klubu;
select * from dane_adresowe into selected_adr where vmiejscowosc=miejscowosc and (vulica=ulica or (vulica is null and ulica is null)) and vnumer_domu=numer_budynku and (vnumer_lokalu=numer_lokalu or (vnumer_lokalu is null and numer_lokalu is null)) and vkod_pocztowy=kod_pocztowy;
	select pesel from zawodnicy into selected_zaw where vpesel=pesel;
	if not found then
	insert into zawodnicy(imie,nazwisko,plec,pesel,id_klubu,dane_adresowe) values(vimie,vnazwisko,plec,vpesel,selected_kl.id_klubu,selected_adr.id_miejsca);
	else
	RAISE NOTICE 'Zawodnik o peselu % już w bazie',selected_zaw.pesel;
	end if;
end ;
$$;