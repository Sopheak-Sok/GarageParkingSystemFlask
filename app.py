from flask import Flask, render_template, request, redirect, url_for, flash, jsonify
# from flask_mysqldb import MySQL
# from config import Config
import mysql.connector
from mysql.connector import connect, Error

app = Flask(__name__)
app.secret_key = "supersecret key"
# MySQL Configuration
mysql_config = {
    'host': 'localhost',
    'user': 'root',
    'password': '***********',
    'database': 'garageparkingdb'
}

# Connect to MySQL
conn = connect(**mysql_config)
cursor = conn.cursor()




@app.route('/')
def index():
    # Connect to the database
    conn = connect(**mysql_config)
    cursor = conn.cursor()
    
    # Query to select all columns from Cars table
    query_cars = "SELECT * FROM Cars"
    cursor.execute(query_cars)
    cars = cursor.fetchall()

    # Query to select all columns from Owners table
    query_owners = "SELECT * FROM Owners"
    cursor.execute(query_owners)
    owners = cursor.fetchall()

    query_slots = "SELECT * FROM parkingslots"
    cursor.execute(query_slots)
    slots = cursor.fetchall()

    # Query to select all columns from Transactions table 
    query_trans = "SELECT * FROM transactions" 
    cursor.execute(query_trans) 
    transactions = cursor.fetchall()


    cursor.close()
    conn.close()
    
    # Pass the fetched data to the template
    return render_template('index.html', cars=cars, owners=owners, slots=slots, transactions=transactions)



@app.route('/add_car', methods=['GET', 'POST'])
def add_car():
    conn = connect(**mysql_config)
    cursor = conn.cursor()
    if request.method == 'POST':
        owner_id = request.form['owner_id']
        make = request.form['make']
        model = request.form['model']
        year = request.form['year']
        color = request.form['color']
        license_plate = request.form['license_plate']
        cursor.callproc("AddCarAndAssignSlot",(owner_id, make, model, year, color, license_plate))
        # mysql.connection.commit()
        conn.commit()
        cursor.close()
        flash('Car Added Successfully!')
        return redirect(url_for('index'))
    return render_template('add_car.html')


@app.route('/add_owner', methods=['GET', 'POST'])
def add_owner():
    conn = connect(**mysql_config)
    cursor = conn.cursor()
    if request.method == 'POST':
        first_name = request.form['first_name']
        last_name = request.form['last_name']
        phone_number = request.form['phone_number']
        email = request.form['email']
        
        # cursor = mysql.connection.cursor()
        cursor.execute("INSERT INTO Owners (FirstName, LastName, PhoneNumber, Email) VALUES (%s, %s, %s, %s)", (first_name, last_name, phone_number, email))
        # mysql.connection.commit()
        conn.commit()
        cursor.close()
        flash('Owner Added Successfully!')
        return redirect(url_for('index'))
    return render_template('add_owner.html')


@app.route('/update_car/<int:id>', methods=['GET', 'POST'])
def update_car(id):
    conn = connect(**mysql_config)
    cursor = conn.cursor()
    
    try:
        # Fetch the car data
        cursor.execute("SELECT * FROM Cars WHERE CarID = %s", (id,))
        car = cursor.fetchone()
        
        if not car:
            flash('Car not found.')
            return redirect(url_for('index'))
        
        # Close cursor after fetching the car data
        cursor.close()

        if request.method == 'POST':
            # Open a new cursor for the update operation
            cursor = conn.cursor()

            owner_id = request.form['owner_id']
            make = request.form['make']
            model = request.form['model']
            year = request.form['year']
            color = request.form['color']
            license_plate = request.form['license_plate']

            try:
                # Update the car details
                cursor.execute(
                    "UPDATE Cars SET OwnerID = %s, Make = %s, Model = %s, Year = %s, Color = %s, LicensePlate = %s WHERE CarID = %s",
                    (owner_id, make, model, year, color, license_plate, id)
                )
                conn.commit()
                flash('Car Updated Successfully!')
                return redirect(url_for('index'))
            except mysql.connector.Error as err:
                print(f"Error: {err}")
                flash('Error updating car. Please try again.')
                return redirect(url_for('update_car', id=id))
            finally:
                cursor.close()

        return render_template('update_car.html', car=car)
    except mysql.connector.Error as err:
        print(f"Error: {err}")
        flash('Error fetching car data. Please try again.')
        return redirect(url_for('index'))
    finally:
        conn.close()

@app.route('/update_owner/<int:id>', methods=['GET', 'POST'])
def update_owner(id):
    conn = connect(**mysql_config)
    cursor = conn.cursor()
    
    try:
        # Fetch the owner data
        cursor.execute("SELECT * FROM Owners WHERE OwnerID = %s", (id,))
        owner = cursor.fetchone()
        
        if not owner:
            flash('Owner not found.')
            return redirect(url_for('index'))
        
        # Close cursor after fetching the car data
        cursor.close()

        if request.method == 'POST':
            # Open a new cursor for the update operation
            cursor = conn.cursor()
            
            first_name = request.form['first_name']
            last_name = request.form['last_name']
            phone_number = request.form['phone_number']
            email = request.form['email']

            try:
                # Update the car details
                cursor.execute(
                    "UPDATE Owners SET FirstName = %s, LastName = %s, PhoneNumber = %s, Email = %s WHERE OwnerID = %s",
                    (first_name, last_name, phone_number, email, id)
                )
                conn.commit()
                flash('Owner Info Updated Successfully!')
                return redirect(url_for('index'))
            except mysql.connector.Error as err:
                print(f"Error: {err}")
                flash("Error updating owner's information. Please try again.")
                return redirect(url_for('update_owner', id=id))
            finally:
                cursor.close()

        return render_template('update_owner.html', owner=owner)
    except mysql.connector.Error as err:
        print(f"Error: {err}")
        flash('Error fetching owner data. Please try again.')
        return redirect(url_for('index'))
    finally:
        conn.close()


@app.route('/update_slots/<int:id>', methods=['GET', 'POST'])
def check_out(id):
    conn = connect(**mysql_config)
    cursor = conn.cursor()

    try:
        # Fetch the owner data
        cursor.execute("SELECT * FROM parkingslots WHERE SlotID = %s", (id,))
        slot = cursor.fetchone()
        
        if not slot:
            flash('Slot not found.')
            return redirect(url_for('index'))
        
        # Close cursor after fetching the slot data
        cursor.close()

        if request.method == 'POST':
            # Open a new cursor for the update operation
            cursor = conn.cursor()
            
            parking_price = request.form['parking_price']

            try:
                # Check Out Car from Slot
                check_out = "RecordParkingTransaction"
                cursor.callproc(check_out, (id,parking_price))
                conn.commit()
                flash('Check Out Car from Slot Info Updated Successfully!')
                return redirect(url_for('index'))
            except mysql.connector.Error as err:
                print(f"Error: {err}")
                flash("Error updating Check Out information. Please try again.")
                return redirect(url_for('check_out', id=id))
            finally:
                cursor.close()

        return render_template('check_out.html', slot=slot)
    except mysql.connector.Error as err:
        print(f"Error: {err}")
        flash('Error fetching slot data. Please try again.')
        return redirect(url_for('index'))
    finally:
        conn.close()


@app.route('/delete_car/<int:id>', methods=['GET', 'POST'])
def delete_car(id):
    conn = connect(**mysql_config)
    cursor = conn.cursor()

    try:
        # First, check if the car exists
        cursor.execute("SELECT * FROM Cars WHERE CarID = %s", (id,))
        car = cursor.fetchone()

        if not car:
            flash('Car not found.')
            return redirect(url_for('index'))

        # Attempt to delete the car
        cursor.execute("DELETE FROM Cars WHERE CarID = %s", (id,))
        conn.commit()
        flash('Car Deleted Successfully!')
    except mysql.connector.Error as err:
        print(f"Error: {err}")
        flash('Error deleting car. Please try again.')
    finally:
        cursor.close()
        conn.close()

    return redirect(url_for('index'))

@app.route('/delete_owner/<int:id>', methods=['GET', 'POST'])
def delete_owner(id):
    conn = connect(**mysql_config)
    cursor = conn.cursor()

    try:
        # First, check if the car exists
        cursor.execute("SELECT * FROM Owners WHERE OwnerID = %s", (id,))
        owner = cursor.fetchone()

        if not owner:
            flash('Owner not found.')
            return redirect(url_for('index'))

        # Attempt to delete the car
        cursor.execute("DELETE FROM Owners WHERE OwnerID = %s", (id,))
        conn.commit()
        flash("Owner's Information Deleted Successfully!")
    except mysql.connector.Error as err:
        print(f"Error: {err}")
        flash("Error deleting owner's info. Please try again.")
    finally:
        cursor.close()
        conn.close()

    return redirect(url_for('index'))

@app.route('/search_owner', methods=['GET', 'POST'])
def search_owner():
    if request.method == 'POST':
        owner_name = request.form['owner_name']
        return redirect(url_for('get_owner', owner_name=owner_name))
    return render_template('search_owner.html')

@app.route('/get_owner')
def get_owner():
    owner_name = request.args.get('owner_name', '')
    conn = connect(**mysql_config)
    cursor = conn.cursor()
    try:
        query = """
            SELECT c.CarID, c.Make, c.Model, c.Year, c.Color, c.LicensePlate,
                    o.FirstName, o.LastName
            FROM Cars c
            JOIN Owners o ON c.OwnerID = o.OwnerID
            WHERE CONCAT(o.FirstName, ' ', o.LastName) LIKE %s
        """
        cursor.execute(query, ('%' + owner_name + '%',))
        owners = cursor.fetchall()
        return render_template('owner_results.html', owners=owners)
    except Error as e:
        print(e)
        flash('Error searching for owner. Please try again.')
        return redirect(url_for('search_owner'))
    finally:
        cursor.close()
        conn.close()

if __name__ == '__main__':
    app.run(debug=True)
