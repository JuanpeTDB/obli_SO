with Ada.Text_IO; use Ada.Text_IO;         
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
with Ada.Numerics.Discrete_Random;  

procedure Vacas is

    -- Variables para contar cuántas vacas hay en cada camión y cuántas están siendo vacunadas
    camion1 : Integer := 0;
    camion2 : Integer := 0;
    vacasVacu : Integer := 0;
    cualCamion : Integer;

    -- Se definen subtipos para limitar los rangos de los números aleatorios
    subtype Range_1_2 is Integer range 1 .. 2;
    subtype Range_1_3 is Integer range 1 .. 3;

    -- Se crean paquetes de números aleatorios para los diferentes rangos
    package Rand_1_2 is new Ada.Numerics.Discrete_Random (Range_1_2);
    package Rand_1_3 is new Ada.Numerics.Discrete_Random (Range_1_3);

    -- Generadores individuales para elegir camión, duración de vacunación y ordeñe
    G_Camion : Rand_1_2.Generator;
    G_Vac : Rand_1_2.Generator;
    G_Ord : Rand_1_3.Generator;

    -- Función que devuelve 1 o 2 al azar para decidir a qué camión va una vaca
    function Random_1_2_Camion return Integer is
    begin
        return Integer (Rand_1_2.Random (G_Camion));
    end Random_1_2_Camion;

    -- Función que devuelve una duración aleatoria entre 1 y 2 segundos (simula vacunación)
    function Random_Vac_Time return Duration is
    begin
        return Duration (Rand_1_2.Random (G_Vac));
    end Random_Vac_Time;

    -- Función que devuelve una duración aleatoria entre 1 y 3 segundos (simula ordeñe)
    function Random_Ord_Time return Duration is
    begin
        return Duration (Rand_1_3.Random (G_Ord));
    end Random_Ord_Time;

    -- Tarea compartida para gestionar la entrada de vacas a los camiones
    task Camion is
        entry entraCamion (V : Integer); -- Entrada para que una vaca solicite subir a un camión
    end Camion;

    -- Cuerpo de la tarea Camion que maneja la lógica de asignación
    task body Camion is
    begin
        loop
            -- Acepta la entrada de una vaca que quiere subir al camión
            accept entraCamion (V : Integer) do
                -- Si el camión 1 está lleno, la vaca va al camión 2
                if camion1 = 50 then
                    camion2 := camion2 + 1;
                    Put_Line ("La vaca" & Integer'Image (V) & " esta entrando al camion 2");
                -- Si el camión 2 está lleno, la vaca va al camión 1
                elsif camion2 = 50 then
                    camion1 := camion1 + 1;
                    Put_Line ("La vaca" & Integer'Image (V) & " esta entrando al camion 1");
                else
                    -- Si ninguno está lleno, se elige aleatoriamente, priorizando que no se exceda el tope
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
                delay 0.5; -- Pequeña espera simulando el tiempo de subida
            end entraCamion;

            -- Se termina el ciclo si ambos camiones están llenos
            exit when camion1 = 50 and camion2 = 50;
        end loop;
    end Camion;

    -- Definición del tipo de tarea Vaca, cada vaca tiene su propia tarea
    task type Vaca is
        entry vacunacion (V : Integer); -- Entrada para iniciar el proceso de vacunación
    end Vaca;

    -- Cuerpo de la tarea Vaca, simula el proceso de cada vaca
    task body Vaca is
        Id : Integer := 0;     -- Identificador único de la vaca
        PudeVacunarse : Boolean := False; -- Flag para saber si la vaca ya fue vacunada

        -- Procedimiento que simula el ordeñe
        procedure ordenie (O : Integer) is
        begin
            Put_Line ("La vaca" & Integer'Image (O) & " esta entrando al area de ordeñe");
            delay Random_Ord_Time; -- Se queda un rato en ordeñe
            Put_Line ("La vaca" & Integer'Image (O) & " esta saliendo del area de ordeñe");
            delay 0.5; -- Breve espera antes de ir al camión
            Camion.entraCamion (O); -- Luego llama a la tarea Camion para subirse
        end ordenie;

    begin
        -- Se acepta el número de identificación de la vaca cuando comienza
        accept vacunacion (V : Integer) do
            Id := V;
        end vacunacion;

        -- Bucle que se repite hasta que la vaca logra vacunarse
        while not PudeVacunarse loop
            -- Solo pueden vacunarse 5 vacas a la vez
            if vacasVacu < 5 then
                vacasVacu := vacasVacu + 1;

                Put_Line ("La vaca" & Integer'Image (Id) & " esta entrando al area de vacunacion");
                delay Random_Vac_Time; -- Se queda un rato vacunándose
                Put_Line ("La vaca" & Integer'Image (Id) & " esta saliendo del area de vacunacion");

                vacasVacu := vacasVacu - 1;
                PudeVacunarse := True;
                delay 0.5; -- Espera antes de ir a ordeñarse
                ordenie (Id); -- Procede al ordeñe
            else
                delay 0.01; -- Espera un poco y vuelve a intentar si ya hay 5 vacas vacunándose
            end if;
        end loop;
    end Vaca;

    -- Se crean 100 tareas de tipo Vaca, una por cada vaca
    misVacas : array (1 .. 100) of Vaca;

begin
    -- Inicializa los generadores de números aleatorios
    Rand_1_2.Reset (G_Camion);
    Rand_1_2.Reset (G_Vac);
    Rand_1_3.Reset (G_Ord);

    -- A cada vaca se le asigna un número de identificación y se inicia su tarea
    for I in misVacas'Range loop
        misVacas(I).vacunacion(I);
    end loop;
end Vacas;
