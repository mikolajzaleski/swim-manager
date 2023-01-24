CREATE OR REPLACE VIEW public.wyniki_zawody AS
 SELECT z.imie,
    z.nazwisko,
    w.czas,
    kk.nazwa_konkurencji,
    z.id_zawodnika,
    za.id_zawodow,
    z.plec,
    za.nazwa,
    kk.id_konkurencji
   FROM (((public.wyniki w
     JOIN public.zawodnicy z ON ((w.id_zawodnika = z.id_zawodnika)))
     JOIN public.konkurencje kk ON ((kk.id_konkurencji = w.id_konkurencji)))
     JOIN public.zawody za ON ((za.id_zawodow = w.id_zawodow)));