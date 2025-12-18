// ======================================================================
// I2C GENERATOR (UVM-Lite Style)
// - Randomizes transactions
// - Supports directed + random mode
// - Sends the transaction to driver via mailbox
// ======================================================================

class i2c_generator;

    // Mailbox to send transactions to the Driver
    mailbox gen2drv;

    // Number of transactions to generate
    int num_transactions;

    // Randomization enable
    bit random_mode;

    // Constructor
    function new(mailbox gen2drv, int num_transactions = 10, bit random_mode = 1);
        this.gen2drv         = gen2drv;
        this.num_transactions = num_transactions;
        this.random_mode      = random_mode;
    endfunction

    // ------------------------------------------------------------------
    // Main Task
    // ------------------------------------------------------------------
    task run();
        i2c_transaction tr;

        for (int i = 0; i < num_transactions; i++) begin
            tr = new();

            if (random_mode) begin
                if (!tr.randomize())
                    $display("ERROR: Randomization failed at iteration %0d", i);
            end
            else begin
                // Directed mode example
                tr.start      = 1;
                tr.slave_addr = 7'h42;
                tr.reg_addr   = i;         // sequential registers
                tr.rw         = (i % 2);   // alternate read/write
                tr.wr_data    = $urandom_range(0,255);
            end

            // Display the generated transaction
            $display("[GENERATOR] Sending Transaction %0d", i);
            tr.display();

            // Send the transaction to driver
            gen2drv.put(tr);

            // Allow some spacing between transactions
            #20;
        end
    endtask

endclass
