clearlog()
-- $todo: aktualisieren, da Änderungen auf MY_Lua durchgeführt
-- $todo: Programmierung für die Erkennung der Gleisbelegung und Setzen Status
-- --------------------------------------------------------
--   lokale Var setzen
-- --------------------------------------------------------
dummy = 0
parkplatz = 0 ; -- 
ampcnt = 0 ; -- Rücksetzen Ampelcount
sodaCnt = 0 ; -- Rücksetzen Zähler für Soda bei Status 3
stdHalt = 50 ; -- 
Signalbild = 0
print ("lokale Var gesetzt")
-- --------------------------------------------------------
--   Gleise registrieren
-- --------------------------------------------------------
EEPRegisterRailTrack(1432) ; -- Lauscha Bhf. rechts 
EEPRegisterRailTrack(1431) ; -- Lauscha Bhf. links 
EEPRegisterRailTrack(1631) ; -- HbfLauscha Bhf. rechts Blick Richtung west, Fahrtrichtung ost
EEPRegisterRailTrack(1131) ; -- HbfLauscha Bhf. links Blick Richtung west, Fahrtrichtung west
--
EEPRegisterRoadTrack(1361) ; -- Soda Rampe 1. Gleis von links, Blick auf Rampe
EEPRegisterRoadTrack(1386) ; -- Soda Rampe 2
EEPRegisterRoadTrack(1354) ; -- Soda Rampe 3
EEPRegisterRoadTrack(1376) ; -- Soda Rampe 4
-- --------------------------------------------------------
--   Signale registrieren
-- --------------------------------------------------------

-- **********************************************************
--          --- Main ---
-- **********************************************************
function EEPMain()

	-- test()
	kreuzung1()
	LauschaBetrieb()
	HBFLauschaBetrieb()
	MainSodaRampeBetrieb() 
    return 1 ; -- <<<< nicht weglöschen, sonst kann EEP nicht laufen
end
-- **********************************************************
--          --- Ende Main ---
-- **********************************************************
function test()
--
-- bGleisLauR, WertGleisLauR = EEPIsRailTrackReserved(1432) ; -- Gleis Lauscha rechts
-- print ("WertGleisLauR " , WertGleisLauR)
-- bGleisLauR, WertGleisLauL = EEPIsRailTrackReserved(1431) ; -- Gleis Lauscha links
-- print ("WertGleisLauL " , WertGleisLauL)
-- --
-- bGleisHbfLauR, WertHbfGleisLauR = EEPIsRailTrackReserved(1631) ; -- Gleis HbfLauscha rechts
-- print ("WertHbfGleisLauR ", WertHbfGleisLauR)
-- bGleisHbfLauR, WertHbfGleisLauL = EEPIsRailTrackReserved(1131) ; -- Gleis HbfLauscha links
-- print ("WertHbfGleisLauL ", WertHbfGleisLauL)
-- --
-- bSlot1, wertSlot1 = EEPLoadData(1)
-- print ("wertSlot1, Stellung Signal 46, Straba blau Busbahnhof " , wertSlot1)
-- bSlot2, wertSlot2 = EEPLoadData(2)
-- print ("wertSlot2, Stellung Signal 45, Straba blau Busbahnhof " , wertSlot2)
-- bSlot5, wertSlot5 = EEPLoadData(5)
-- print ("wertSlot5, Anz. Gleisbelegungen in Lauscha " , wertSlot5)
-- --
-- bSlot6, wertSlot6 = EEPLoadData(6)
-- print ("wertSlot6, Anz. Gleisbelegungen HBF, Lauschabahn " , wertSlot6)
-- --
-- bSlot10, wertSlot10 = EEPLoadData(10)
-- print ("wertSlot10, Anz. Fahrzeuge (Bus) nach Brücke " , wertSlot10)
-- bSlot11, wertSlot11 = EEPLoadData(11)
-- print ("wertSlot11, Anz. Straba Bürostadt Süd " , wertSlot11)
-- bSlot12, wertSlot12 = EEPLoadData(12)
-- print ("wertSlot12, Anz. Straba Bürostadt Süd " , wertSlot12)
-- --
-- bSlot20, wertSlot20 = EEPLoadData(20)
-- print ("wertSlot20" , wertSlot20)
Weichenstellung192 = EEPGetSwitch( 192 )
print ("Weihenstellung_192 " , Weichenstellung192 )
end ; -- end function
-- *********************************************************
--  Güterbahnhof
-- *********************************************************
function GBfEinfahrtSued ()
-- Einfahrt in Güterbahnhof Südseite vom Gleis 2D links
-- warten, ob Signal 268 auf Halt bleibt
   print ("GBfEinfahrtSued")
	EEPSetSignal(268, 2) ; -- Halt
	EEPSetSignal(203, 2) ; -- Halt

end -- end function
-- *********************************************************
--  Hauptbahnhof Betrieb
-- *********************************************************
function HBFBetrieb ()
	-- ------------------------------
	--   Gleis 400 Hauptgleis Richtung ost nach west (links)
	-- ------------------------------
	HbfGleisOk, Hbf400Besetzt = EEPIsRailTrackReserved(400)
	if Hbf400Besetzt then
		print("Gleis 400 Hbf besetzt")
		ZugGleis400 ()
	end -- end if
end -- end function


-- *********************
--  Kreuzung1
-- *********************
-- Kreuzung in der Stadt
function kreuzung1()
	ampA1 = 81
	ampA2 = 25
	ampB1 = 22
	ampB2 = 31
	ampelschaltungKreuzung(ampA1, ampA2, ampB1, ampB2)
end -- end function
-- *********************
--   Abbiegen von Bussen (links) und Auto (rehts) nach der Brücke in die Landstrasse
-- *********************

-- Fahrzeug (Bus) nach der Brücke zählen
function einfahrtFahrzeug()
	bSlot10, wertSlot10 = EEPLoadData(10)
	wertSlot10 = wertSlot10 + 1
	EEPSaveData(10, wertSlot10)
	-- print("einfahrtFahrzeug(), slot10: ", wertSlot10)
end ; -- end function

-- Fahrzeug nach der Brücke zurücksetzen
function ausfahrFahrzeug()
	bSlot10, wertSlot10 = EEPLoadData(10)
	if wertSlot10 > 0 then
		wertSlot10 = wertSlot10 - 1
		EEPSaveData(10, wertSlot10)
		if wertSlot10 == 0 then
			EEPSetSwitch(68, 1) ; -- Fahrt
		end ; -- end if
	end ; -- end if
	-- print("ausfahrtFahrzeug() Slot10: ", wertSlot10 )
end ; -- end function
-- *********************
-- Einfahrt Straba Linie Blau in Busbahnhof
-- *********************
function busBhStrabaBlau()

	-- print("busBhStrabaBlau()")
	EEPSetSignal(50, 2)

	positSignal45 = EEPGetSignal(45)
    if positSignal45 == 0 then
	-- print("Signal 45 existiert nicht")
    elseif positSignal45 == 2 then
		EEPSaveData(2, "sig45_hat_Halt")
    end ; -- end if

    bSlot2, wertSlot2 = EEPLoadData(2)
	-- print(wertSlot2)

end ; -- end function


-- ------------------------------
-- Prüfung ob die Fahrstrasse für StrabaGelb frei geschaltet wurde
-- ------------------------------
function fahrstrStrabaGelb()

	-- print("fahrstrStrabaGelb")
	EEPSaveData(1, nil)
	positSignal46 = EEPGetSignal(46)
    if positSignal46 == 0 then
		print("Signal 46 existiert nicht")
    elseif positSignal46 == 2 then
		EEPSaveData(1, "sig46_hat_Halt")
    end ; -- end if

    bSlot1, wertSlot1 = EEPLoadData(1)
	-- print(wertSlot1)

end ; -- end function


-- ----------------------------------------
-- Prüfung ob die Fahrstrasse für StrabaBlau frei geschaltet wurde
-- ----------------------------------------
function fahrstrStrabaBlau()

	-- print("fahrstrStrabaBlau")
	EEPSaveData(2, nil)
	positSignal45 = EEPGetSignal(45)
    if positSignal45 == 0 then
		print("Signal 45 existiert nicht")
    elseif positSignal45 == 2 then
		EEPSaveData(2, "sig45_hat_Halt")
    end ; -- end if

    bSlot1, wertSlot1 = EEPLoadData(2)
	-- print(wertSlot1)

end ; -- end function

-- ----------------------------------------
-- nachziehen von Straba, wenn eine Fahrstrasse nicht geschaltet werden konnte
-- ----------------------------------------
function nachziehenStraba()

 -- print("nachziehenStraba")
 bSlot1, wertSlot1 = EEPLoadData(1)
 bSlot2, wertSlot2 = EEPLoadData(2)

  if bSlot2 then
  	EEPSetSignal(50, 2)
	-- print ("nachziehen Straba blau")
  end
  if bSlot1 then
  	EEPSetSignal(48, 2)
	-- print ("nachziehen Straba gelb")
  end
  EEPSaveData(1, nil)
  EEPSaveData(2, nil)
end ; -- end function



-- ****************************************
-- Ampelsteuerung, Subfunction für Standard Ampelschaltung für einfache Kreuzung
-- ****************************************
-- Lösung durch hochzählen der Var.: ampcnt
-- eine Sekunde entspricht 4 bis 5 Zählern
--

-- Ampel DE 1 West
-- Stellung 1 = grün
-- Stellung 4 = rot
--
-- Bogenampel mit hellem Licht, Ampel 4 mehrbegriffig
-- Stellung 4 = gelb blinkend, ohne Halt
-- Stellung 3 = gelb mit Halt
-- Stellung 2 = rot
-- Stellung 1 = grün

function ampelschaltungKreuzung(ampA1, ampA2, ampB1, ampB2)

	ampcnt = ampcnt + 1
	-- print("Ampelschaltung", ampA1, ampA2, ampB1, ampB2 , "   tdiff:", tdiff , "ampcnt: ", ampcnt)

	if ampcnt <  25 then ; -- 0 bis 24 alles auf rot
		EEPSetSignal (ampA1,4)
		EEPSetSignal (ampA2,4)
		EEPSetSignal (ampB1,4)
		EEPSetSignal (ampB2,4)
		-- print("alles rot")
	elseif ampcnt < 150 then ; -- 30 bis 149 Phase 1
		EEPSetSignal (ampA1,1)
		EEPSetSignal (ampA2,1)
		EEPSetSignal (ampB1,4)
		EEPSetSignal (ampB2,4)
		-- print("Phase 1")
	elseif ampcnt <  180 then ; -- 155 bis 179 alles auf rot 2
		EEPSetSignal (ampA1,4)
		EEPSetSignal (ampA2,4)
		EEPSetSignal (ampB1,4)
		EEPSetSignal (ampB2,4)
		-- print("alles auf rot 2")
	elseif ampcnt < 300 then ; -- 185 bis 299 Phase 2
		EEPSetSignal (ampA1,4)
		EEPSetSignal (ampA2,4)
		EEPSetSignal (ampB1,1)
		EEPSetSignal (ampB2,1)
		EEPSetSwitch(169, 2) ; -- Fahrt 2
		-- print("Phase 2")
	elseif ampcnt == 300 or tdiff > 300 then ; -- ab 300
		ampcnt = 0
	end ; -- end if
	-- *********************************************************
	--    Schaltung neue V11 Kreuzungen
	-- *********************************************************
	if ampcnt ==  0 then
		EEPSetSwitch(169, 1) ; -- Fahrt 1
	elseif ampcnt == 150 then
		EEPSetSwitch(169, 2) ; -- Fahrt 2
	end ; -- end if
end ; -- end function

-- ****************************************
-- Steuerung Strassenbahnüberfahrten von und aus der Bürostadt
-- ****************************************
-- Slot 11 : Einfahrt von Süd
-- Slot 20 : Einfahrt von Nord

-- ----------------------
-- Steuerung  Süd
-- ----------------------
function BueroStrabaSuedEin()
	bSlot11, wertSlot11 = EEPLoadData(11)
	wertSlot11 = wertSlot11 + 1
	EEPSaveData(11, wertSlot11)
	BueroStrabaAmpelsteuerungSued()
	-- print ("wertSlot11: " , wertSlot11)
end ; -- end function

function BueroStrabaSuedaus()
	bSlot11, wertSlot11 = EEPLoadData(11)
	wertSlot11 = wertSlot11 - 1
	EEPSaveData(11, wertSlot11)
	BueroStrabaAmpelsteuerungSued()
	-- print ("wertSlot11: " , wertSlot11)
end ; -- end function

-- ----------------------
-- Steuerung  Nord
-- ----------------------
function BueroStrabaNordEin()
	bSlot20, wertSlot20 = EEPLoadData(20)
	wertSlot20 = wertSlot20 + 1
	EEPSaveData(20, wertSlot20)
	BueroStrabaAmpelsteuerungNord()
	-- print ("wertSlot20: " , wertSlot20)
end ; -- end function

function BueroStrabaNordaus()
	bSlot20, wertSlot20 = EEPLoadData(20)
	wertSlot20 = wertSlot20 - 1
	EEPSaveData(20, wertSlot20)
	BueroStrabaAmpelsteuerungNord()
	--print ("wertSlot20: " , wertSlot20)
end ; -- end function

-- ----------------------
-- Steuerung der Ampeln
-- ----------------------
function BueroStrabaAmpelsteuerungSued()
	bSlot11, wertSlot11 = EEPLoadData(11)
	if wertSlot11 == 0 then
		EEPSetSignal (83,1) ; -- Fahrt
		EEPSetSignal (84,1) ; -- Fahrt
		EEPSetSignal (072,2) ; -- Halt
		EEPSetSignal (138,2) ; -- Halt
	elseif wertSlot11 > 0 then
		EEPSetSignal (83,2) ; -- Halt
		EEPSetSignal (84,2) ; -- Halt
		EEPSetSignal (072,1) ; -- Fahrt
		EEPSetSignal (138,1) ; -- Fahrt
	elseif wertSlot11 < 0 then ; -- Fehler, Slot wird auf 0 gesetzt
		EEPSaveData(11, 0)
	end ; -- end if
end ; -- end function

function BueroStrabaAmpelsteuerungNord()
	bSlot20, wertSlot20 = EEPLoadData(20)
	if wertSlot20 == 0 then
		EEPSetSignal (153,1) ; -- Fahrt
		EEPSetSignal (154,1) ; -- Fahrt
		EEPSetSignal (75,2) ; -- Halt
		EEPSetSignal (74,2) ; -- Halt
	elseif wertSlot20 > 0 then
		EEPSetSignal (153,2) ; -- Halt
		EEPSetSignal (154,2) ; -- Halt
		EEPSetSignal (75,1) ; -- Fahrt
		EEPSetSignal (74,1) ; -- Fahrt
	elseif wertSlot20 < 0 then ; -- Fehler, Slot wird auf 0 gesetzt
		EEPSaveData(20, 0)
	end ; -- end if
end ; -- end function
-- ****************************************
-- Steuerung Zugstrecke Lauscha
-- ****************************************

-- merken der Gleisbelegung in Lauscha, Slot: 5
-- LauschaL = linkes Gleis in Richtung Lauscha,
-- LauschaR = rechtes Gleis in Richtung Lauscha,

-- In Lauscha können ein oder beide Züge manuell ausgetauscht werden.
-- Der Lauschabetrieb muss dafür unterbrochen werden.
-- Das Signal 0233 muss dazu auf halt gestellt werden und es muss gewartet werden,
-- bis beide Züge in Lauscha sind. 
-- Bei Signal 0233 = "Fahrt" läuft der Lauschabetrieb normal weiter.

function LauschaBetrieb() ; -- function ist in main
	bGleisLauR, WertGleisLauR = EEPIsRailTrackReserved(1432) ; -- Gleis Lauscha rechts
	bGleisLauL, WertGleisLauL = EEPIsRailTrackReserved(1431) ; -- Gleis Lauscha links
	bSlot5, wertSlot5 = EEPLoadData(5)
	sig0233 = EEPGetSignal(0233); -- Blindsignal in Lauscha
	if sig0233 == 1 then ; -- halt => Lauschabetrieb unterbrochen
		return ; -- ein Lauschazug kann ausgetauscht werden
		-- print ("Lauscha Halt")
	elseif wertSlot5 ~= 0 then
	    -- print ("Slot5 ne 0")
		abfahrtLauscha()	
	elseif WertGleisLauR == true and WertGleisLauL == true then ; -- beide Gleise besetzt
		-- print ("beide Gleise in Lauscha besetzt")
		EEPSaveData(5, EEPTime)
	end
end ; -- end function

function abfahrtLauscha()
	bSlot5, wertSlot5 = EEPLoadData(5)
	-- print ("function abfahrtLauscha xxx slot 5: ",wertSlot5 )
	if EEPTime > wertSlot5 + stdHalt then ; -- Abfahrt rechter Zug
		EEPSetSignal(96, 1) ; -- rechtes Signal auf Fahrt
		EEPSaveData(5, 0)
		-- print ("Fahrt links")
	end ; -- end if
end ; -- end function
-- Der linke Zug wird durch Signalkontakt vom rechten Zug "nachgezogen"
-- ****************************************
-- Steuerung Hauptbahnhof Strecke Lauscha
-- ****************************************
-- merken der Gleisbelegung im HBF, Slot: 6

-- Steuerung Abfahrt der Lauschazüge im HBf
-- wenn beide Züge im Bahnhof sind, zwei Minuten warten dann Abfahrt
-- *******************************************************
-- umstellen auf Gleisbelegungsabfrage
-- *******************************************************
function HBFLauschaBetrieb() ; -- function ist in main
	bGleisHbfLauR, WertHbfGleisLauR = EEPIsRailTrackReserved(1631) ; -- Gleis HbfLauscha rechts
	bGleisHbfLauR, WertHbfGleisLauL = EEPIsRailTrackReserved(1131) ; -- Gleis HbfLauscha links
	bSlot6, wertSlot6 = EEPLoadData(6)
	if wertSlot6 ~= 0 then
		abfahrtHbfLauscha()	
	elseif WertHbfGleisLauR == true and WertHbfGleisLauL == true then ; -- beide Gleise besetzt
		-- print ("beide Gleise in HbfLauscha besetzt")
		EEPSaveData(6, EEPTime)
	end
end ; -- end function

function abfahrtHbfLauscha()
	-- print ("function abfahrtHbfLauscha ")
	bSlot6, wertSlot6 = EEPLoadData(6)
	if EEPTime > wertSlot6 + stdHalt then ; -- Abfahrt rechter Zug
		EEPSetSignal(106, 1) ; -- rechtes Signal auf Fahrt
		EEPSaveData(6, 0)
		-- print ("Fahrt rechts")
	end ; -- end if
end ; -- end function
-- *******************************************************
-- Steuerung der LKWs für die Laderampe in der Sodafabrik
-- *******************************************************
--	Slot 30 ist der Status
--
-- Weiche 192 ist die Abzweigung in Richtung SodaEinfahrt_01
--		Stellung 1: Fahrt 
--		Stellung 2: Abzweig, die Gegenverkehrampel ist auf halt


function MainSodaRampeBetrieb() ; -- von Main aufger. Funktion *******
	-- -------------------------
	--	Steuerung Rampe unterbrechen
	--	------------------------
	-- Signalbild = EEPGetSignal( 385 )
	-- print ("Status: " , wertSlot30 )
	-- print ("Signalbild: " , Signalbild)
	-- if Signalbild == 4 then  ; -- Halt
	-- 	print( "Signal 385 auf 4 => Betrieb Rampe gestopt" )
	-- 	return
	-- end ; -- end-if Signalbild == 4
	-- -------------------------
	--	Steuerung Rampe einschalten
	--	------------------------
	bSlot30, wertSlot30 = EEPLoadData(30)
	if wertSlot30 == 3 then
		sodaCnt = sodaCnt + 1
		if sodaCnt > 300 then
			EEPSaveData(30, 4); -- Ausfahrt kann starten
		end ; -- end-if
	end ; -- end if wertSlot30 == 3
	
	bSlot30, wertSlot30 = EEPLoadData(30)
	if wertSlot30 == 4 then
		alleHilfssigAufFahrt()
		EEPSaveData(30, 5); -- LKW in Richtung Ausfahrt unterwegs
		SodaSuchenParkplatz ()
		if parkplatz == 0 then ; -- alle Gleise belegt
			EEPSetSignal (198 , 1) ; -- Fahrt für Rampe 4
		elseif parkplatz == 4 then
			EEPSetSignal (356 , 1) ; -- Fahrt für Rampe 3
		elseif parkplatz == 3 then
			EEPSetSignal (353 , 1) ; -- Fahrt für Rampe 2
		elseif parkplatz == 2 then
			EEPSetSignal (350 , 1) ; -- Fahrt für Rampe 1
		else
			print ("Fehler: Abräumphase, parkplatz hat unerw.Wert: " , parkplatz)
		end ; -- end-if
	end; -- end-if
end ; -- MainSodaRampeBetrieb()

-- **************
-- Funktionen für Kontakte
-- **************
-- Weiche auf Abzweig, wenn Status = 1, Position kurz vor Weiche
-- $todo: 
--	Kontakt alle Routen, Weiche 192 => Fahrt
--	Kontakt für diese Funktion setzen (kurz vor Weiche), Route LKW
--	Kontakt nach der Weiche auf dem Abzweigweg: LUA-Funktion: SodaEinfahrt()
--	Subfunktion SuchenParkplatz realisieren
function SodaAbzweig()
	bSlot30, wertSlot30 = EEPLoadData(30)
	print ("Status: " , wertSlot30 )
	if wertSlot30 == 1 then
		print ("SodaAbzweig")
		EEPSetSwitch( 192 , 2 ) ; -- Abzweig
	end ; -- end if wertSlot30 == 1 then
end  ; -- SodaAbzweig()

-- LKW ist in die Einfahrt eingebogen, Status auf 2 setzen, 
--	Position: auf dem Einfahrweg, direkt hinter der Einfahrtweiche 
--	bis der LKW in der Parkposition ist, soll kein weiterer LKW einfahren

function SodaEinfahrt()
	print ("SodaEinfahrt() Status auf 2")
	EEPSaveData(30, 2) ; -- LKW ist eingefahren
	SodaSuchenParkplatz ()
	print ("Parkplatz: " , parkplatz)
	if parkplatz == 1 then
		EEPSetSignal (351 , 2)
		EEPSetSignal (352 , 1)
		EEPSetSignal (354 , 1)
		EEPSetSignal (355 , 1)
	end ; -- end if
	if parkplatz == 2 then
		EEPSetSignal (351 , 1)
		EEPSetSignal (352 , 2)
		EEPSetSignal (354 , 1)
		EEPSetSignal (355 , 1)
	end ; -- end if
	if parkplatz == 3 then
		EEPSetSignal (351 , 1)
		EEPSetSignal (352 , 1)
		EEPSetSignal (354 , 2)
		EEPSetSignal (355 , 1)
	end ; -- end if
	if parkplatz == 4 then
		EEPSetSignal (351 , 1)
		EEPSetSignal (352 , 1)
		EEPSetSignal (354 , 1)
		EEPSetSignal (355 , 2)
	end ; -- end if
	if parkplatz == 0 then
		print ("Fehlersituation: LKW währt ein")
		print ("aber keine Rampe frei")
		alleHilfssigAufFahrt() ; -- LKW muss wieder raus
	end ; -- end-if

end ; -- SodaEinfahrt()

function SodaStatusAktualisieren()
	SodaSuchenParkplatz ()
	if parkplatz == 0 then ; -- alle Rampen besetzt
		EEPSaveData(30, 3) 
	else
		EEPSaveData(30, 1) ; -- nachster LKW kann einfahren 
	end ; -- end if
	bSlot30, wertSlot30 = EEPLoadData(30)
	print("Status aktualisiert:", wertSlot30)
end ; -- SodaStatusAktualisieren

function SodaAusfahrt()
	SodaSuchenParkplatz ()
	if parkplatz == 1 then ; -- alle LKW sind raus
		EEPSaveData(30, 1) ; -- nächster LKW kann rein
	else
		EEPSaveData(30, 4) ; -- nächster LKW kann raus
	end ; -- end-if
	bSlot30, wertSlot30 = EEPLoadData(30)
	print("SodaAusfahrt(): Status; ", wertSlot30)
end ; -- SodaAusfahrt()


-- Testfunktion: Status auf einen Wert setzen
function SodaSetStatus()
	-- EEPSaveData(30, 1)
	bSlot30, wertSlot30 = EEPLoadData(30)
	print("SodaSetStatus() Test: ", wertSlot30)
end ; -- SodaSetStatus


-- **************
-- Subfunktionen
-- **************
-- Rampen 1 bis 4 von links nach rechts 
function SodaSuchenParkplatz()
	parkplatz = 0
	sg04ok, sg04Besetzt = EEPIsRoadTrackReserved(1376)
	if sg04Besetzt ~= true then
	  parkplatz = 4
	  print ("parkplatz:" , parkplatz)
	end -- end if

		
	sg03ok, sg03Besetzt = EEPIsRoadTrackReserved(1354)
	if sg03Besetzt ~= true then
	  parkplatz = 3
	  print ("parkplatz:" , parkplatz)
	end -- end if

		
	sg02ok, sg02Besetzt = EEPIsRoadTrackReserved(1386)
	if sg02Besetzt ~= true then
	  parkplatz = 2
	  print ("parkplatz:" , parkplatz)
	end -- end if
	
	sg01ok, sg01Besetzt = EEPIsRoadTrackReserved(1361)
	print ("Track1" , sg01Besetzt)
	if sg01Besetzt ~= true then 
	  parkplatz = 1
	  print ("parkplatz:" , parkplatz)
	end -- end if
	
end ; -- SodaSuchenParkplatz


function alleHilfssigAufFahrt()
	EEPSetSignal (351 , 1) ; -- alle Hilfssig auf Fahrt
	EEPSetSignal (352 , 1)
	EEPSetSignal (354 , 1)
	EEPSetSignal (355 , 1)
end ; -- alleHilfssigAufFahrt()
