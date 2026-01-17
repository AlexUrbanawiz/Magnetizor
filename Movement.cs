using Godot;

public partial class Movement : CharacterBody2D
{
	[Export]
	public int Speed { get; set; } = 400;
	
	[Export]
	public float RotationSpeed { get; set; } = 3f;

	private float _rotationDirection;
	
	public bool rotateWithMouse = false;
	
	public void GetInput()
	{
		if(Input.IsActionJustPressed("swapRotation"))
		{
			rotateWithMouse = !rotateWithMouse;
		}
		
		if(rotateWithMouse)
		{
			LookAt(GetGlobalMousePosition());
		}
		else
		{			_rotationDirection = Input.GetAxis("rotateLeft", "rotateRight");
		}
		float inputDirection = Input.GetAxis("left", "right");
		Velocity = new Vector2(inputDirection * Speed, 0);
	}

	public override void _PhysicsProcess(double delta)
	{
		GetInput();
		if(!rotateWithMouse)
		{
			Rotation += _rotationDirection * RotationSpeed * (float)delta;
		}
		MoveAndSlide();
	}	
}
