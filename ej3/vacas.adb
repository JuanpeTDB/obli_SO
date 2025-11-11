with Ada.Text_IO;         use Ada.Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
with Ada.Numerics.Discrete_Random;

procedure Vacas is

    camion1   : Integer := 0;
    camion2   : Integer := 0;
    vacasVacu : Integer := 0;
    cualCamion: Integer;

    -- Rangos para randoms
    subtype Range_1_2 is Integer range 1 .. 2;
    subtype Range_1_3 is Integer range 1 .. 3;

    package Rand_1_2 is new Ada.Numerics.Discrete_Random (Range_1_2);
    package Rand_1_3 is new Ada.Numerics.Discrete_Random (Range_1_3);

    -- Generadores separados (HECHOS CON CHATGPT)
    G_Camion : Rand_1_2.Generator;
    G_Vac    : Rand_1_2.Generator;
    G_Ord    : Rand_1_3.Generator;

    -- Random para elegir camión (1 o 2)
    function Random_1_2_Camion return Integer is
    begin
        return Integer (Rand_1_2.Random (G_Camion));
    end Random_1_2_Camion;

    -- Random demora vacunación: 1..2 segundos
    function Random_Vac_Time return Duration is
    begin
        return Duration (Rand_1_2.Random (G_Vac));
    end Random_Vac_Time;

    -- Random demora ordeñe: 1..3 segundos
    function Random_Ord_Time return Duration is
    begin
        return Duration (Rand_1_3.Random (G_Ord));
    end Random_Ord_Time;

    task Camion is
        entry entraCamion (V : Integer);
    end Camion;

    task body Camion is
    begin
        loop
            accept entraCamion (V : Integer) do
                if camion1 = 50 then
                    camion2 := camion2 + 1;
                    Put_Line ("La vaca" & Integer'Image (V) & " esta entrando al camion 2");
                elsif camion2 = 50 then
                    camion1 := camion1 + 1;
                    Put_Line ("La vaca" & Integer'Image (V) & " esta entrando al camion 1");
                else
                    cualCamion := Random_1_2_Camion;
                    if (cualCamion = 1 and then camion1 < 50)
                       or else camion2 = 50
                    then
                        camion1 := camion1 + 1;
                        Put_Line ("La vaca" & Integer'Image (V) & " esta entrando al camion 1");
                    else
                        camion2 := camion2 + 1;
                        Put_Line ("La vaca" & Integer'Image (V) & " esta entrando al camion 2");
                    end if;
                end if;
                delay 0.5; 
            end entraCamion;

            exit when camion1 = 50 and camion2 = 50;
        end loop;
    end Camion;
    
    task type Vaca is
        entry vacunacion (V : Integer);
    end Vaca;

    task body Vaca is
        Id            : Integer := 0;
        PudeVacunarse : Boolean := False;

        procedure ordenie (O : Integer) is
        begin
            Put_Line ("La vaca" & Integer'Image (O) & " esta entrando al area de ordeñe");
            delay Random_Ord_Time; 
            Put_Line ("La vaca" & Integer'Image (O) & " esta saliendo del area de ordeñe");
            delay 0.5;
            Camion.entraCamion (O);
        end ordenie;

    begin
        accept vacunacion (V : Integer) do
            Id := V;
        end vacunacion;

        while not PudeVacunarse loop
            if vacasVacu < 5 then
                vacasVacu := vacasVacu + 1;

                Put_Line ("La vaca" & Integer'Image (Id) & " esta entrando al area de vacunacion");
                delay Random_Vac_Time;
                Put_Line ("La vaca" & Integer'Image (Id) & " esta saliendo del area de vacunacion");

                vacasVacu := vacasVacu - 1;
                PudeVacunarse := True;
                delay 0.5;
                ordenie (Id);
            else
                delay 0.01;
            end if;
        end loop;
    end Vaca;

    misVacas : array (1 .. 100) of Vaca;

begin
    Rand_1_2.Reset (G_Camion);
    Rand_1_2.Reset (G_Vac);
    Rand_1_3.Reset (G_Ord);

    for I in misVacas'Range loop
        misVacas(I).vacunacion(I);
    end loop;
end Vacas;
