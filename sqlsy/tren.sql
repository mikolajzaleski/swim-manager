CREATE OR REPLACE PROCEDURE public.dodaj_trenera(IN vimie character varying, IN vnazwisko character varying, IN vpesel numeric, IN vulica character varying, IN vkod_pocztowy character varying, IN vmiejscowosc character varying, IN vnumer_domu integer, IN vnumer_lokalu integer, IN vnazwa_klubu character varying)
    LANGUAGE plpgsql
    AS $$
declare
selected_adr dane_adresowe%rowtype;
selected_tre trenerzy%rowtype;
selected_kl kluby%rowtype;
begin

select * from dane_adresowe into selected_adr where vmiejscowosc=miejscowosc and (vulica=ulica or(vulica is null and ulica is null) ) and vnumer_domu=numer_budynku and (vnumer_lokalu=numer_lokalu or (vnumer_lokalu is null and numer_lokalu is null)) and vkod_pocztowy=kod_pocztowy;
if not found then
	RAISE NOTICE 'DODAJE ADRES';
	insert into dane_adresowe(miejscowosc,ulica,numer_budynku,numer_lokalu,kod_pocztowy) values(vmiejscowosc,vulica,vnumer_domu,vnumer_lokalu,vkod_pocztowy);
end if;

select * from kluby into selected_kl where nazwa_klubu=vnazwa_klubu;
if not found then
	RAISE NOTICE 'DODAJE KLUB';
	insert into kluby(nazwa_klubu) values(vnazwa_klubu);
end if;

select * from dane_adresowe into selected_adr where vmiejscowosc=miejscowosc and (vulica=ulica or (vulica is null and ulica is null) ) and vnumer_domu=numer_budynku and (vnumer_lokalu=numer_lokalu or (vnumer_lokalu is null and numer_lokalu is null) ) and vkod_pocztowy=kod_pocztowy;
select * from kluby into selected_kl where nazwa_klubu=vnazwa_klubu;
	RAISE NOTICE 'ADRES %',selected_adr.ulica;
    RAISE NOTICE 'KLUB_ID %',selected_kl.id_klubu;
select pesel from trenerzy into selected_tre where vpesel=pesel;
	
if not found then
	insert into trenerzy(imie,nazwisko,pesel,id_klubu,id_adresu) values(vimie,vnazwisko,vpesel,selected_kl.id_klubu,selected_adr.id_miejsca);
else 
	RAISE NOTICE 'Trener o peselu % już w bazie',selected_tre.pesel;
end if;
end ;
$$;

